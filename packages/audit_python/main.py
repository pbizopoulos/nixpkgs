#!/usr/bin/env python3
"""Audit Python package."""

import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

import typer
from rich import print as rprint

app: typer.Typer = typer.Typer()


def _run_command(cmd: list[str], env: dict[str, str] | None = None) -> int:
    """Run command and print output."""
    process = subprocess.Popen(  # noqa: S603
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        env=env,
        text=True,
    )
    if process.stdout:
        for line in process.stdout:
            rprint(line, end="")
    process.wait()
    return process.returncode


@app.command()  # type: ignore[untyped-decorator]
def profile(
    nixpkgs_url: str,
) -> None:
    """Run `DEBUG=1 <url>` under scalene and coverage, showing results in stdout."""
    nix_bin = shutil.which("nix") or "nix"
    python_bin = shutil.which("python3") or "python3"
    rprint(f"[bold green]Resolving {nixpkgs_url}[/bold green]")
    try:
        res = subprocess.run(  # noqa: S603
            [nix_bin, "build", "--no-link", "--print-out-paths", nixpkgs_url],
            capture_output=True,
            text=True,
            check=True,
        )
        out_path = res.stdout.strip()
        if out_path:
            bin_name = (
                nixpkgs_url.rsplit("#", maxsplit=1)[-1]
                if "#" in nixpkgs_url
                else Path(nixpkgs_url).name
            )
            bin_path = Path(out_path) / "bin" / bin_name
            wrapped_path = bin_path.parent / f".{bin_path.name}-wrapped"
            base_cmd = [str(wrapped_path)] if wrapped_path.exists() else [str(bin_path)]
        else:
            base_cmd = [nix_bin, "run", nixpkgs_url]
    except subprocess.CalledProcessError:
        rprint(
            "[yellow]Could not resolve nixpkgs_url to a path, using `nix run`[/yellow]",
        )
        base_cmd = [nix_bin, "run", nixpkgs_url]
    with tempfile.TemporaryDirectory() as tmp_dir:
        env = os.environ.copy()
        env["DEBUG"] = "1"
        env["COVERAGE_FILE"] = str(Path(tmp_dir) / ".coverage")
        rprint(f"[bold green]Running Scalene on {base_cmd}[/bold green]")
        scalene_cmd = [
            python_bin,
            "-m",
            "scalene",
            "--cli",
            "--no-browser",
            *base_cmd,
        ]
        rc = _run_command(scalene_cmd, env=env)
        if rc != 0:
            rprint("[red]Scalene run failed[/red]")
            sys.exit(rc)
        rprint("\n[bold green]Running Coverage + Scalene[/bold green]")
        coverage_cmd = [
            python_bin,
            "-m",
            "coverage",
            "run",
            "-m",
            "scalene",
            "--cli",
            "--no-browser",
            *base_cmd,
        ]
        rc = _run_command(coverage_cmd, env=env)
        if rc != 0:
            rprint("[red]Coverage run failed[/red]")
            sys.exit(rc)
        rprint("\n[bold blue]Coverage Report:[/bold blue]")
        subprocess.run([python_bin, "-m", "coverage", "report"], env=env, check=False)  # noqa: S603
        rprint("\n[bold blue]Dead Code Detection (Vulture):[/bold blue]")
        vulture_cmd = [python_bin, "-m", "vulture", *base_cmd]
        _run_command(vulture_cmd, env=env)


if __name__ == "__main__":
    app()
