#!/usr/bin/env python3
"""Generate Python-produced artifacts for a LaTeX build."""

from __future__ import annotations

import os
import shutil
from pathlib import Path

import matplotlib as mpl

mpl.use("Agg")
import matplotlib.pyplot as plt
import pandas as pd


def template_root(script_path: Path) -> Path:
    """Resolve the directory that contains ms.tex/ms.bib assets."""
    candidates = [
        script_path.parent,
        script_path.parent.parent,
    ]
    for candidate in candidates:
        if (candidate / "ms.tex").is_file():
            return candidate
    msg = "Could not find ms.tex for the python_latex_template package."
    raise FileNotFoundError(msg)


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
    lines = [
        "\\begin{tabular}{lr}",
        "\\toprule",
        "Metric & Value \\\\",
        "\\midrule",
    ]
    for row in frame.itertuples(index=False):
        lines.append(f"{row.Metric} & {row.Value:.2f} \\\\")
    lines.extend(["\\bottomrule", "\\end{tabular}", ""])
    latex = "\n".join(lines)
    path.write_text(latex, encoding="utf-8")


def main() -> None:
    """Generate the build workspace artifacts for LaTeX compilation."""
    destination_root = Path.cwd().resolve()
    if not os.access(destination_root, os.W_OK):
        destination_root = Path("/tmp/python_latex_template")
        destination_root.mkdir(parents=True, exist_ok=True)
    script_path = Path(__file__).resolve()
    source_root = template_root(script_path)
    workspace = destination_root / "tmp"
    workspace.mkdir(parents=True, exist_ok=True)
    ms_tex = workspace / "ms.tex"
    ms_tex.unlink(missing_ok=True)
    shutil.copy2(source_root / "ms.tex", ms_tex)
    bib_path = source_root / "ms.bib"
    if bib_path.exists():
        ms_bib = workspace / "ms.bib"
        ms_bib.unlink(missing_ok=True)
        shutil.copy2(bib_path, ms_bib)
    create_figure(workspace / "figure.png")
    create_table(workspace / "table.tex")


if __name__ == "__main__":
    main()
