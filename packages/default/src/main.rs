use anyhow::{Context, Result};
use clap::{Arg, ArgAction, Command};
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command as std_command;
fn main() -> Result<()> {
    if std::env::var("DEBUG").as_deref() == Ok("1") {
        run_tests()?;
        return Ok(());
    }
    let matches = parse_args()?;
    let target_dir_str = matches
        .get_one::<String>("directory")
        .expect("directory is mandatory");
    let target_dir = Path::new(target_dir_str);
    let mut templates_to_copy = Vec::new();
    let available_templates = get_available_templates()?;
    for (flag, path) in available_templates {
        if matches.get_flag(&flag) {
            templates_to_copy.push(path);
        }
    }
    if target_dir.exists() {
        println!("Target directory exists, running nix fmt...");
        let status = std_command::new("nix")
            .arg("fmt")
            .current_dir(target_dir)
            .status()
            .context("Failed to run nix fmt")?;
        if !status.success() {
            anyhow::bail!("nix fmt failed in target directory");
        }
    } else {
        println!("Creating target directory: {:?}", target_dir);
        fs::create_dir_all(target_dir).context("Failed to create target directory")?;
    }
    let root_dir = get_root_dir()?;
    let flake_nix_src = root_dir.join("flake.nix");
    if flake_nix_src.exists() {
        fs::copy(&flake_nix_src, target_dir.join("flake.nix"))
            .context("Failed to copy flake.nix")?;
    }
    for template_path in templates_to_copy {
        let template_name = template_path.file_name().and_then(|s| s.to_str()).unwrap();
        let dest_path = target_dir.join("packages").join(template_name);
        fs::create_dir_all(&dest_path)
            .context("Failed to create template destination directory")?;
        println!("Copying template {} to {:?}", template_name, dest_path);
        let mut options = fs_extra::dir::CopyOptions::new();
        options.content_only = true;
        fs_extra::dir::copy(&template_path, &dest_path, &options)
            .context(format!("Failed to copy template {}", template_name))?;
    }
    Ok(())
}
fn get_available_templates() -> Result<Vec<(String, PathBuf)>> {
    let root_dir = get_root_dir()?;
    let packages_dir = root_dir.join("packages");
    let mut templates = Vec::new();
    if packages_dir.exists() {
        for entry in fs::read_dir(packages_dir)? {
            let entry = entry?;
            let path = entry.path();
            if path.is_dir() {
                if let Some(name) = path.file_name().and_then(|s| s.to_str()) {
                    if name.ends_with("_template") {
                        let flag = name.trim_end_matches("_template").to_string();
                        templates.push((flag, path));
                    }
                }
            }
        }
    }
    Ok(templates)
}
fn get_root_dir() -> Result<PathBuf> {
    let mut current_dir = std::env::current_dir()?;
    loop {
        if current_dir.join("flake.nix").exists() {
            return Ok(current_dir);
        }
        if let Some(parent) = current_dir.parent() {
            current_dir = parent.to_path_buf();
        } else {
            anyhow::bail!("Could not find root directory (containing flake.nix)");
        }
    }
}
fn parse_args() -> Result<clap::ArgMatches> {
    let mut cmd = Command::new("default")
        .about("Project initializer CLI")
        .arg(
            Arg::new("directory")
                .help("The directory to initialize")
                .required(true)
                .index(1),
        );
    let templates = get_available_templates()?;
    for (flag, _) in templates {
        let flag_leak: &'static str = Box::leak(flag.into_boxed_str());
        cmd = cmd.arg(
            Arg::new(flag_leak)
                .long(flag_leak)
                .action(ArgAction::SetTrue),
        );
    }
    Ok(cmd.get_matches())
}
fn run_tests() -> Result<()> {
    println!("Running tests...");
    let root = get_root_dir().context("Failed to get root dir")?;
    assert!(root.join("flake.nix").exists());
    println!("test_get_root_dir ... ok");
    let templates = get_available_templates().context("Failed to get available templates")?;
    assert!(!templates.is_empty());
    assert!(templates.iter().any(|(flag, _)| flag == "rust"));
    println!("test_get_available_templates ... ok");
    println!("All tests passed!");
    Ok(())
}
