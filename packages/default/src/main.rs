use anyhow::{Context, Result};
use clap::{Arg, ArgAction, Command};
use std::fs;
use std::os::unix::fs::PermissionsExt;
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
    if !target_dir.exists() {
        println!("Creating target directory: {:?}", target_dir);
        fs::create_dir_all(target_dir).context("Failed to create target directory")?;
    }
    println!("Initializing git repository in {:?}", target_dir);
    std_command::new("git")
        .arg("init")
        .current_dir(target_dir)
        .status()
        .context("Failed to run git init")?;
    if target_dir.join("flake.nix").exists() {
        println!("Target directory has flake.nix, running nix fmt...");
        std_command::new("git")
            .arg("add")
            .arg("flake.nix")
            .current_dir(target_dir)
            .status()
            .ok();
        let status = std_command::new("nix")
            .arg("fmt")
            .current_dir(target_dir)
            .status()
            .context("Failed to run nix fmt")?;
        if !status.success() {
            anyhow::bail!("nix fmt failed in target directory");
        }
    }
    let root_dir = get_root_dir()?;
    let flake_nix_src = root_dir.join("flake.nix");
    if flake_nix_src.exists() {
        let dest = target_dir.join("flake.nix");
        if dest.exists() {
            fs::remove_file(&dest).ok();
        }
        fs::copy(&flake_nix_src, &dest).context("Failed to copy flake.nix")?;
        fs::set_permissions(&dest, fs::Permissions::from_mode(0o644)).ok();
        let content = fs::read_to_string(&dest).context("Failed to read copied flake.nix")?;
        let new_content = content.replace(
            "inputs = {",
            "inputs = {\n    canonicalization.url = \"github:pbizopoulos/canonicalization\";",
        );
        fs::write(&dest, new_content).context("Failed to write modified flake.nix")?;
        std_command::new("git")
            .arg("add")
            .arg("flake.nix")
            .current_dir(target_dir)
            .status()
            .ok();
    }
    let formatter_nix_src = root_dir.join("formatter.nix");
    if formatter_nix_src.exists() {
        let dest = target_dir.join("formatter.nix");
        if dest.exists() {
            fs::remove_file(&dest).ok();
        }
        fs::copy(&formatter_nix_src, &dest).context("Failed to copy formatter.nix")?;
        fs::set_permissions(&dest, fs::Permissions::from_mode(0o644)).ok();
        let content = fs::read_to_string(&dest).context("Failed to read copied formatter.nix")?;
        let new_content =
            content.replace("inputs.self.packages", "inputs.canonicalization.packages");
        fs::write(&dest, new_content).context("Failed to write modified formatter.nix")?;
        std_command::new("git")
            .arg("add")
            .arg("formatter.nix")
            .current_dir(target_dir)
            .status()
            .ok();
    }
    for template_path in templates_to_copy {
        let template_name = template_path.file_name().and_then(|s| s.to_str()).unwrap();
        let dest_path = target_dir.join("packages").join(template_name);
        fs::create_dir_all(&dest_path)
            .context("Failed to create template destination directory")?;
        println!("Copying template {} to {:?}", template_name, dest_path);
        let mut options = fs_extra::dir::CopyOptions::new();
        options.content_only = true;
        options.overwrite = true;
        if dest_path.exists() {
            fs::remove_dir_all(&dest_path).ok();
            fs::create_dir_all(&dest_path).ok();
        }
        fs_extra::dir::copy(&template_path, &dest_path, &options)
            .context(format!("Failed to copy template {}", template_name))?;
        set_permissions_recursive(&dest_path).ok();
        std_command::new("git")
            .arg("add")
            .arg(format!("packages/{}", template_name))
            .current_dir(target_dir)
            .status()
            .ok();
    }
    Ok(())
}
fn set_permissions_recursive(path: &Path) -> Result<()> {
    let metadata = fs::metadata(path)?;
    if path.is_dir() {
        fs::set_permissions(path, fs::Permissions::from_mode(0o755))?;
        for entry in fs::read_dir(path)? {
            set_permissions_recursive(&entry?.path())?;
        }
    } else {
        fs::set_permissions(path, fs::Permissions::from_mode(0o644))?;
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
    if let Ok(root) = std::env::var("CANONICALIZATION_ROOT") {
        return Ok(PathBuf::from(root));
    }
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
    if root.join("flake.nix").exists() {
        assert!(root.join("formatter.nix").exists());
        println!("test_get_root_dir ... ok");
    } else {
        println!(
            "Skipping root dir checks because flake.nix not found in {:?}",
            root
        );
    }
    let templates = get_available_templates().context("Failed to get available templates")?;
    if !templates.is_empty() {
        assert!(templates.iter().any(|(flag, _)| flag == "rust"));
        println!("test_get_available_templates ... ok");
    } else {
        println!(
            "Skipping templates checks because no templates found in {:?}",
            root
        );
    }
    println!("All tests passed!");
    Ok(())
}
#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::tempdir;
    #[test]
    fn test_all() -> Result<()> {
        run_tests()
    }
    #[test]
    fn test_set_permissions_recursive() -> Result<()> {
        let dir = tempdir()?;
        let file_path = dir.path().join("test.txt");
        fs::write(&file_path, "test")?;
        set_permissions_recursive(dir.path())?;
        let dir_metadata = fs::metadata(dir.path())?;
        assert_eq!(dir_metadata.permissions().mode() & 0o777, 0o755);
        let file_metadata = fs::metadata(&file_path)?;
        assert_eq!(file_metadata.permissions().mode() & 0o777, 0o644);
        Ok(())
    }
    #[test]
    fn test_get_root_dir_from_env() -> Result<()> {
        std::env::set_var("CANONICALIZATION_ROOT", "/tmp");
        let root = get_root_dir()?;
        assert_eq!(root, PathBuf::from("/tmp"));
        std::env::remove_var("CANONICALIZATION_ROOT");
        Ok(())
    }
}
