import difflib
import os
import unittest
from pathlib import Path
from typing import Any, cast
import fire
import libcst
from libcst import matchers as m


def _get_sort_key(node: libcst.FunctionDef) -> str:
    if m.matches(
            node,
            m.FunctionDef(
                decorators=[m.Decorator(decorator=m.Name("property"))])):
        return "0" + cast(str, node.name.value)
    if node.name.value.startswith("_"):
        return "2" + cast(str, node.name.value)
    return "1" + cast(str, node.name.value)


class _CSTTransformer(libcst.CSTTransformer):  # type: ignore[misc]

    def _alphabetize_statements(self, updated_node: Any) -> Any:
        if isinstance(updated_node, libcst.Module):
            body = updated_node.body
        elif isinstance(updated_node, libcst.ClassDef):
            body = updated_node.body.body
        else:
            return updated_node
        statements = list(body)
        first_idx = -1
        class_and_func_nodes = []
        for i, node in enumerate(statements):
            if isinstance(node, (libcst.ClassDef, libcst.FunctionDef)):
                if first_idx == -1:
                    first_idx = i
                class_and_func_nodes.append(node)
        if first_idx == -1:
            return updated_node
        classes = [
            n for n in class_and_func_nodes if isinstance(n, libcst.ClassDef)
        ]
        functions = [
            n for n in class_and_func_nodes
            if isinstance(n, libcst.FunctionDef)
        ]
        sorted_classes = sorted(classes, key=lambda n: n.name.value)
        sorted_functions = sorted(functions, key=_get_sort_key)
        new_statements = list(statements[:first_idx])
        new_statements.extend(sorted_classes)
        new_statements.extend(sorted_functions)
        for i in range(first_idx, len(statements)):
            node = statements[i]
            if not isinstance(node, (libcst.ClassDef, libcst.FunctionDef)):
                new_statements.append(node)
        if isinstance(updated_node, libcst.Module):
            return updated_node.with_changes(body=tuple(new_statements))
        return updated_node.with_changes(body=updated_node.body.with_changes(
            body=tuple(new_statements)))

    def leave_ClassDef(self, original_node: libcst.ClassDef,
                       updated_node: libcst.ClassDef) -> libcst.ClassDef:
        return self._alphabetize_statements(updated_node)

    def leave_Module(self, original_node: libcst.Module,
                     updated_node: libcst.Module) -> libcst.Module:
        return self._alphabetize_statements(updated_node)


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
            return (None if isinstance(input_str_or_bytes, str) else
                    code_unparsed.encode())
    return None


class _TestCase(unittest.TestCase):

    def test_alphabetize_python_bytes_input(self) -> None:
        parent_path = Path(__file__).resolve().parent
        with (parent_path / "prm/main_before.py").open() as file:
            code_output_before = alphabetize_python(file.read().encode())
        with (parent_path / "prm/main_after.py").open() as file:
            code_output_after = file.read()
        if isinstance(code_output_before, bytes):
            decoded_output = code_output_before.decode()
            if decoded_output != code_output_after:
                diff = difflib.unified_diff(
                    code_output_after.splitlines(),
                    decoded_output.splitlines(),
                    fromfile="expected",
                    tofile="actual",
                )
                print("\n" + "\n".join(diff))  # noqa: T201
                raise AssertionError


def main() -> None:
    """Alphabetize Python."""
    fire.Fire(alphabetize_python)


if __name__ == "__main__":
    if os.getenv("DEBUG"):
        unittest.main()
    else:
        main()
