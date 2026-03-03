#!/usr/bin/env python3
"""Alphabetize Python."""

from __future__ import annotations

import difflib
import os
import unittest
from pathlib import Path

import fire
import libcst


def _get_sort_key(node: libcst.FunctionDef) -> str:
    decorator_str = ""
    for decorator in node.decorators:
        dec = decorator.decorator
        if hasattr(dec, "value"):
            if hasattr(dec.value, "value"):
                decorator_str += dec.value.value
            elif isinstance(dec.value, str):
                decorator_str += dec.value
        elif (
            hasattr(dec, "func")
            and hasattr(dec.func, "value")
            and hasattr(dec.func.value, "value")
        ):
            decorator_str += dec.func.value.value
    if decorator_str:
        return f"@{decorator_str}{node.name.value}"
    node_name_value: str = node.name.value
    return node_name_value


class _CSTTransformer(libcst.CSTTransformer):  # type: ignore[misc]
    def leave_ClassDef(  # noqa: N802
        self,
        original_node: libcst.ClassDef,  # noqa: ARG002
        updated_node: libcst.ClassDef,
    ) -> libcst.ClassDef:
        body = updated_node.body
        statements = list(body.body)
        if not statements:
            return updated_node.with_changes(body=body)
        function_nodes = []
        other_nodes = []
        for node in statements:
            if isinstance(node, libcst.FunctionDef):
                function_nodes.append(node)
            else:
                other_nodes.append(node)
        sorted_functions = sorted(function_nodes, key=_get_sort_key)
        init_index = -1
        for i, func_node in enumerate(sorted_functions):
            if func_node.name.value == "__init__":
                init_index = i
                break
        if init_index != -1:
            init_node = sorted_functions.pop(init_index)
            sorted_functions.insert(0, init_node)
        return updated_node.with_changes(
            body=body.with_changes(
                body=tuple(other_nodes + sorted_functions),
            ),
        )

    def leave_FunctionDef(  # noqa: N802
        self,
        original_node: libcst.FunctionDef,  # noqa: ARG002
        updated_node: libcst.FunctionDef,
    ) -> libcst.FunctionDef:
        return updated_node

    def leave_Module(  # noqa: N802
        self,
        original_node: libcst.Module,  # noqa: ARG002
        updated_node: libcst.Module,
    ) -> libcst.Module:
        statements = list(updated_node.body)
        if not statements:
            return updated_node
        first_idx = -1
        class_and_func_nodes = []
        for i, node in enumerate(statements):
            if isinstance(node, (libcst.ClassDef, libcst.FunctionDef)):
                if first_idx == -1:
                    first_idx = i
                class_and_func_nodes.append(node)
        if first_idx == -1:
            return updated_node
        classes = [n for n in class_and_func_nodes if isinstance(n, libcst.ClassDef)]
        functions = [
            n for n in class_and_func_nodes if isinstance(n, libcst.FunctionDef)
        ]
        sorted_classes = sorted(classes, key=lambda n: n.name.value)
        sorted_functions = sorted(functions, key=_get_sort_key)
        new_statements = statements[:first_idx]
        new_statements.extend(sorted_classes)
        new_statements.extend(sorted_functions)
        for i in range(first_idx, len(statements)):
            node = statements[i]
            if not isinstance(node, (libcst.ClassDef, libcst.FunctionDef)):
                new_statements.append(node)
        return updated_node.with_changes(body=tuple(new_statements))


def alphabetize_python(*args: str | bytes) -> str | bytes | None:
    """Alphabetize Python."""
    for input_str_or_bytes in args:
        if isinstance(input_str_or_bytes, str):
            with Path(input_str_or_bytes).open() as file:
                content = file.read()
        else:
            content = input_str_or_bytes.decode()
        cst = libcst.parse_module(content)
        cst_transformer = _CSTTransformer()
        modified_tree = cst.visit(cst_transformer)
        code_unparsed: str = modified_tree.code
        if isinstance(input_str_or_bytes, str):
            with Path(input_str_or_bytes).open("w") as file:
                file.write(code_unparsed)
        if len(args) == 1:
            return (
                None if isinstance(input_str_or_bytes, str) else code_unparsed.encode()
            )
    return None


class _TestCase(unittest.TestCase):
    def test_alphabetize_python_bytes_input(self) -> None:
        parent_path = Path(__file__).resolve().parent
        with (parent_path / "prm/main_before.py").open() as file:
            code_output_before = alphabetize_python(file.read().encode())
        with (parent_path / "prm/main_after.py").open() as file:
            code_output_after = file.read()
        if code_output_before.decode() != code_output_after:  # type: ignore[union-attr]
            diff = difflib.unified_diff(
                code_output_after.splitlines(),
                code_output_before.decode().splitlines(),  # type: ignore[union-attr]
                fromfile="expected",
                tofile="actual",
            )
            print("\n" + "\n".join(diff))  # noqa: T201
            raise AssertionError

    def test_alphabetize_python_shebang(self) -> None:
        code_input = b"#!/usr/bin/env python3\nimport sys\nprint(sys.argv)\n"
        code_output = alphabetize_python(code_input)
        if code_output != code_input:
            raise AssertionError


def main() -> None:
    """Alphabetize Python."""
    fire.Fire(alphabetize_python)


if __name__ == "__main__":
    if os.getenv("DEBUG"):
        unittest.main()
    else:
        main()
