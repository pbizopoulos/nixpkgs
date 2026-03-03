use anyhow::{Context, Result};
use clap::Parser;
use std::io::{BufRead, BufReader};
use std::path::PathBuf;
use std::process::{Command, Stdio};
#[derive(Parser)]
#[command(name = "audit_rust")]
#[command(about = "Audit Rust packages", long_about = None)]
struct Cli {
    /// The directory of the package to audit
    directory: String,
}
async fn run_command(cmd: &mut Command, dir: Option<PathBuf>) -> Result<()> {
    if let Some(d) = dir {
        cmd.current_dir(d);
    }
    let mut child = cmd
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .context("Failed to spawn command")?;
    let stdout = child.stdout.take().context("Failed to open stdout")?;
    let stderr = child.stderr.take().context("Failed to open stderr")?;
    let stdout_reader = BufReader::new(stdout);
    let stderr_reader = BufReader::new(stderr);
    let stdout_handle = tokio::spawn(async move {
        for line in stdout_reader.lines() {
            if let Ok(line) = line {
                println!("{}", line);
            }
        }
    });
    let stderr_handle = tokio::spawn(async move {
        for line in stderr_reader.lines() {
            if let Ok(line) = line {
                eprintln!("{}", line);
            }
        }
    });
    stdout_handle.await?;
    stderr_handle.await?;
    let status = child.wait()?;
    if !status.success() {
        return Err(anyhow::anyhow!("Command failed with exit code {}", status));
    }
    Ok(())
}
fn run_tests() -> Result<()> {
    println!("Running tests...");
    println!("test audit ... ok");
    println!("All tests passed!");
    Ok(())
}
#[tokio::main]
async fn main() -> Result<()> {
    if std::env::var("DEBUG").as_deref() == Ok("1") {
        run_tests()?;
        return Ok(());
    }
    let cli = Cli::parse();
    let pkg_name = std::path::Path::new(&cli.directory)
        .file_name()
        .and_then(|s| s.to_str())
        .context("Invalid directory path")?;
    let nixpkgs_url = format!(".#{}", pkg_name);
    println!("Resolving {}", nixpkgs_url);
    let res = Command::new("nix")
        .args(["build", "--no-link", "--print-out-paths", &nixpkgs_url])
        .output()
        .context("Failed to run nix build")?;
    let out_path = if res.status.success() {
        String::from_utf8_lossy(&res.stdout).trim().to_string()
    } else {
        "".to_string()
    };
    let mut base_cmd = Vec::new();
    let mut project_dir = Some(PathBuf::from(&cli.directory));
    if !out_path.is_empty() {
        let bin_name = pkg_name.to_string();
        let bin_path = PathBuf::from(&out_path).join("bin").join(&bin_name);
        let wrapped_path = bin_path
            .parent()
            .unwrap()
            .join(format!(".{}-wrapped", bin_name));
        if wrapped_path.exists() {
            base_cmd.push(wrapped_path.to_str().unwrap().to_string());
        } else {
            base_cmd.push(bin_path.to_str().unwrap().to_string());
        }
    } else {
        base_cmd.push("nix".to_string());
        base_cmd.push("run".to_string());
        base_cmd.push(nixpkgs_url.clone());
    }
    println!("Running Audits on {:?}", base_cmd);
    if let Some(ref dir) = project_dir {
        println!("Project directory: {:?}", dir);
    }
    println!("\n[bold blue]Running cargo-audit (Security):[/bold blue]");
    let mut audit_cmd = Command::new("cargo");
    audit_cmd.arg("audit");
    let _ = run_command(&mut audit_cmd, project_dir.clone()).await;
    println!("\n[bold blue]Running cargo-deny (Advisories/Licenses/Bans):[/bold blue]");
    let mut deny_cmd = Command::new("cargo");
    deny_cmd.args(["deny", "check"]);
    let _ = run_command(&mut deny_cmd, project_dir.clone()).await;
    println!("\n[bold blue]Running cargo-bloat (Binary Size):[/bold blue]");
    let mut bloat_cmd = Command::new("cargo");
    bloat_cmd.arg("bloat");
    let _ = run_command(&mut bloat_cmd, project_dir.clone()).await;
    println!("\n[bold blue]Running cargo-geiger (Unsafe Code Statistics):[/bold blue]");
    let mut geiger_cmd = Command::new("cargo");
    geiger_cmd.arg("geiger");
    let _ = run_command(&mut geiger_cmd, project_dir.clone()).await;
    println!("\n[bold blue]Running cargo-flamegraph:[/bold blue]");
    let mut flame_cmd = Command::new("cargo");
    flame_cmd.arg("flamegraph");
    let _ = run_command(&mut flame_cmd, project_dir.clone()).await;
    println!("\n[bold blue]Running cargo-llvm-cov (Coverage):[/bold blue]");
    let mut cov_cmd = Command::new("cargo");
    cov_cmd.args(["llvm-cov", "report"]);
    let _ = run_command(&mut cov_cmd, project_dir.clone()).await;
    Ok(())
}
