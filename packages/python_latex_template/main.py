#!/usr/bin/env python3
"""Generate Python-produced artifacts for a LaTeX build."""

from __future__ import annotations

import os
from pathlib import Path

import matplotlib as mpl

mpl.use("Agg")
import matplotlib.pyplot as plt
import pandas as pd


def create_figure(path: Path) -> None:
    """Create a small deterministic figure for the LaTeX document."""
    figure, axis = plt.subplots(figsize=(5, 3))
    x_values = [1, 2, 3, 4]
    y_values = [1, 4, 9, 16]
    axis.plot(x_values, y_values, color="#1f77b4", linewidth=2.5, marker="o")
    axis.set_xlabel("Input")
    axis.set_ylabel("Squared output")
    if os.getenv("DEBUG"):
        axis.set_title("Python-generated figure (in DEBUG mode)")
    else:
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
    lines.extend(
        f"{row.Metric} & {row.Value:.2f} \\\\" for row in frame.itertuples(index=False)
    )
    lines.extend(["\\bottomrule", "\\end{tabular}", ""])
    latex = "\n".join(lines)
    path.write_text(latex, encoding="utf-8")


def main() -> None:
    """Generate the build workspace artifacts for LaTeX compilation."""
    workspace = Path.cwd().resolve() / "tmp"
    workspace.mkdir(parents=True, exist_ok=True)
    create_figure(workspace / "figure.png")
    create_table(workspace / "table.tex")


if __name__ == "__main__":
    main()
