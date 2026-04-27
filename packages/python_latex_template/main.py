#!/usr/bin/env python3
"""Generate Python-produced artifacts for a LaTeX build."""

from __future__ import annotations

import os
import shutil
import subprocess
from pathlib import Path

import matplotlib as mpl

mpl.use("Agg")
import matplotlib.pyplot as plt
import pandas as pd


def template_root() -> Path:
    """Return the directory that stores the LaTeX template assets."""
    script_path = Path(__file__).resolve()
    candidates = [
        script_path.parent,
        script_path.parent.parent / script_path.name,
        script_path.parent.parent / "python_latex_template",
    ]
    for candidate in candidates:
        if (candidate / "ms.tex").is_file():
            return candidate
    msg = "Could not find ms.tex for the python_latex_template package."
    raise FileNotFoundError(msg)


def output_root() -> Path:
    """Return the root directory that should receive the tmp workspace."""
    return Path.cwd().resolve()


def create_figure(path: Path) -> None:
    """Create a small deterministic figure for the LaTeX document."""
    figure, axis = plt.subplots(figsize=(5, 3))
    x_values = [1, 2, 3, 4]
    y_values = [1, 4, 9, 16]
    axis.plot(x_values, y_values, color="#1f77b4", linewidth=2.5, marker="o")
    axis.set_xlabel("Input")
    axis.set_ylabel("Squared output")
    axis.set_title("Python-generated figure")
    axis.grid(alpha=0.3)
    figure.tight_layout()
    figure.savefig(path, dpi=200)
    plt.close(figure)


def create_table(path: Path) -> None:
    """Create a LaTeX table with pandas."""
    frame = pd.DataFrame(
        {
            "Metric": ["mean", "median", "max"],
            "Value": [7.50, 6.50, 16.00],
        },
    )
    latex = frame.to_latex(index=False, float_format=lambda value: f"{value:.2f}")
    path.write_text(latex, encoding="utf-8")


def create_workspace(destination_root: Path) -> Path:
    """Populate the tmp workspace with generated artifacts and TeX sources."""
    source_root = template_root()
    workspace = destination_root / "tmp"
    workspace.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source_root / "ms.tex", workspace / "ms.tex")
    bib_path = source_root / "ms.bib"
    if bib_path.exists():
        shutil.copy2(bib_path, workspace / "ms.bib")
    create_figure(workspace / "figure.png")
    create_table(workspace / "table.tex")
    return workspace


def compile_document(workspace: Path) -> Path:
    """Compile the LaTeX document inside the tmp workspace."""
    latexmk_bin = shutil.which("latexmk")
    if latexmk_bin is None:
        msg = "latexmk is required to compile the LaTeX template."
        raise FileNotFoundError(msg)
    subprocess.run(  # noqa: S603
        [latexmk_bin, "-pdf", "-interaction=nonstopmode", "ms.tex"],
        check=True,
        cwd=workspace,
        env={**os.environ, "HOME": str(workspace)},
        stderr=subprocess.DEVNULL,
        stdout=subprocess.DEVNULL,
    )
    return workspace / "ms.pdf"


def render_document(destination_root: Path) -> Path:
    """Build the workspace and compile the PDF."""
    workspace = create_workspace(destination_root)
    return compile_document(workspace)


def main() -> None:
    """Generate the build workspace and compile the PDF."""
    pdf_path = render_document(output_root())
    print(f"PDF: {pdf_path}")  # noqa: T201


if __name__ == "__main__":
    main()
