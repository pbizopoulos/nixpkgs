#!/usr/bin/env python3
import os
import subprocess
import sys
import tempfile
from pathlib import Path

import typer
from rich import print

app = typer.Typer()


def _run_command(cmd, env=None):
    process = subprocess.Popen(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        env=env,
        text=True,
    )
    for line in process.stdout:
        print(line, end="")
    process.wait()
    return process.returncode


@app.command()
def profile(
    nixpkgs_url: str,
) -> None:
    """Run `DEBUG=1 <url>` under scalene and coverage, showing results in stdout."""
    print(f"[bold green]Resolving {nixpkgs_url}[/bold green]")
    try:
        res = subprocess.run(
            ["nix", "build", "--no-link", "--print-out-paths", nixpkgs_url],
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
            base_cmd = ["nix", "run", nixpkgs_url]
    except subprocess.CalledProcessError:
        print(
            "[yellow]Could not resolve nixpkgs_url to a path, using `nix run`[/yellow]"
        )
        base_cmd = ["nix", "run", nixpkgs_url]
    with tempfile.TemporaryDirectory() as tmp_dir:
        env = os.environ.copy()
        env["DEBUG"] = "1"
        env["COVERAGE_FILE"] = str(Path(tmp_dir) / ".coverage")
        print(f"[bold green]Running Scalene on {base_cmd}[/bold green]")
        scalene_cmd = [
            "python3",
            "-m",
            "scalene",
            "--cli",
            "--no-browser",
            *base_cmd,
        ]
        rc = _run_command(scalene_cmd, env=env)
        if rc != 0:
            print("[red]Scalene run failed[/red]")
            sys.exit(rc)
        print("\n[bold green]Running Coverage + Scalene[/bold green]")
        coverage_cmd = [
            "python3",
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
            print("[red]Coverage run failed[/red]")
            sys.exit(rc)
        print("\n[bold blue]Coverage Report:[/bold blue]")
        subprocess.run(["python3", "-m", "coverage", "report"], env=env)
        print("\n[bold blue]Dead Code Detection (Vulture):[/bold blue]")
        vulture_cmd = ["python3", "-m", "vulture", *base_cmd]
        _run_command(vulture_cmd, env=env)


if __name__ == "__main__":
    app()
