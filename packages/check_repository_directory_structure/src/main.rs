use clap::Parser;
use git2::{Repository, StatusOptions};
use regex::Regex;
use std::collections::HashSet;
use std::path::Path;
use walkdir::WalkDir;
#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
struct Args {
    #[arg(default_value = ".")]
    dir_name: String,
    #[arg(short, long)]
    fix: bool,
}
fn is_valid_fqdn(name: &str) -> bool {
    let re = Regex::new(r"^([a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,}$").unwrap();
    re.is_match(name)
}
fn is_dash_case(name: &str) -> bool {
    let re = Regex::new(r"^[a-z0-9]+([-.][a-z0-9]+)*$").unwrap();
    re.is_match(name)
}
fn main() {
    let args = Args::parse();
    if std::env::var("DEBUG").as_deref() == Ok("1") {
        run_tests();
    } else {
        match check_repository_directory_structure(args.dir_name, args.fix) {
            Ok(_) => std::process::exit(0),
            Err(warnings) => {
                println!("{}", warnings.join("\n"));
                std::process::exit(1);
            }
        }
    }
}
fn check_repository_directory_structure(dir_name: String, fix: bool) -> Result<(), Vec<String>> {
    let mut warnings = Vec::new();
    let dir_path = Path::new(&dir_name)
        .canonicalize()
        .expect("Failed to canonicalize path");
    let repo = Repository::discover(&dir_path).expect("Not a git repository");
    let working_dir = repo.workdir().expect("No working directory for repository");
    if fix {
        let output = std::process::Command::new("git")
            .args(["clean", "-df"])
            .current_dir(working_dir)
            .output()
            .expect("Failed to execute git clean");
        if !output.stdout.is_empty() {
            print!("{}", String::from_utf8_lossy(&output.stdout));
        }
    } else {
        let mut status_options = StatusOptions::new();
        status_options.include_untracked(true);
        let statuses = repo
            .statuses(Some(&mut status_options))
            .expect("Failed to get statuses");
        for entry in statuses.iter() {
            if entry.status().is_wt_new() {
                warnings.push(format!(
                    "{}/{}: is untracked",
                    working_dir.display(),
                    entry.path().unwrap()
                ));
            }
        }
    }
    let head = repo.head().expect("Failed to get HEAD");
    let branch_name = head.shorthand().expect("Failed to get branch name");
    if branch_name != "main" {
        warnings.push(format!(
            "{}: should have 'main' as the active branch",
            working_dir.display()
        ));
    }
    let branches = repo
        .branches(Some(git2::BranchType::Local))
        .expect("Failed to get branches");
    if branches.count() != 1 {
        warnings.push(format!(
            "{}: should have only one branch",
            working_dir.display()
        ));
    }
    let dir_name_str = working_dir.file_name().unwrap().to_str().unwrap();
    if dir_name_str == dir_name_str.to_lowercase()
        && !is_valid_fqdn(dir_name_str)
        && !is_dash_case(dir_name_str)
    {
        warnings.push(format!(
            "{}: should be lower-case and valid FQDN or in dash-case",
            working_dir.display()
        ));
    }
    let mut paths = Vec::new();
    for entry in WalkDir::new(working_dir).into_iter().filter_entry(|e| {
        let path = e.path();
        if path == working_dir {
            return true;
        }
        let rel_path = path.strip_prefix(working_dir).unwrap();
        for component in rel_path.components() {
            let s = component.as_os_str().to_str().unwrap();
            if s == "tmp" || s == "prm" || s == "target" {
                return false;
            }
        }
        true
    }) {
        let entry = entry.expect("Failed to read directory entry");
        if entry.path() != working_dir {
            paths.push(entry.path().to_path_buf());
        }
    }
    paths.sort();
    let mut dir_and_file_names = HashSet::new();
    for path in &paths {
        let rel_path = path.strip_prefix(working_dir).unwrap();
        let is_leaf = path.is_file() || !paths.iter().any(|p| p.parent() == Some(path));
        if is_leaf {
            dir_and_file_names.insert(rel_path.to_path_buf());
        }
    }
    let names_allowed = [
        r"\.git(/.*)?",
        r"\.github/workflows/workflow\.yml",
        r"\.gitignore",
        r"CITATION\.bib",
        r"LICENSE",
        r"README",
        r"checks/[^/]+/default\.nix",
        r"flake\.lock",
        r"flake\.nix",
        r"formatter\.nix",
        r"prm(/.*)?",
        r"result",
        r"secrets(/.*)?",
    ];
    let file_dependencies = [
        (
            r"hosts/[^/]+/configuration\.nix",
            vec![
                r"hosts/[^/]+/\.terraform(/.*)?",
                r"hosts/[^/]+/\.terraform\.lock\.hcl",
                r"hosts/[^/]+/deploy-requirements\.sh",
                r"hosts/[^/]+/deploy\.sh",
                r"hosts/[^/]+/hardware-configuration\.nix",
                r"hosts/[^/]+/main\.tf",
                r"hosts/[^/]+/prm(/.*)?",
                r"hosts/[^/]+/tmp(/.*)?",
            ],
        ),
        (
            r"packages/[^/]+/default\.nix",
            vec![
                r"packages/[^/]+/prm(/.*)?",
                r"packages/[^/]+/result",
                r"packages/[^/]+/tmp(/.*)?",
            ],
        ),
        (
            r"packages/[^/]+/Cargo\.toml",
            vec![
                r"packages/[^/]+/Cargo\.lock",
                r"packages/[^/]+/default\.nix",
                r"packages/[^/]+/result",
                r"packages/[^/]+/src(/.*)?",
            ],
        ),
        (
            r"packages/[^/]+/package\.json",
            vec![
                r"packages/[^/]+/app(/.*)?",
                r"packages/[^/]+/default\.nix",
                r"packages/[^/]+/next\.config\.mjs",
                r"packages/[^/]+/package-lock\.json",
                r"packages/[^/]+/postcss\.config\.mjs",
                r"packages/[^/]+/tailwind\.config\.ts",
                r"packages/[^/]+/tsconfig\.json",
            ],
        ),
        (
            r"packages/[^/]+/index\.html",
            vec![
                r"CNAME",
                r"packages/[^/]+/default\.nix",
                r"packages/[^/]+/script\.js",
                r"packages/[^/]+/style\.css",
            ],
        ),
        (
            r"packages/[^/]+/main\.c",
            vec![r"packages/[^/]+/default\.nix"],
        ),
        (
            r"packages/[^/]+/ms\.tex",
            vec![r"packages/[^/]+/default\.nix", r"packages/[^/]+/ms\.bib"],
        ),
        (
            r"packages/[^/]+/Main\.hs",
            vec![
                r"packages/[^/]+/default\.nix",
                r"packages/[^/]+/main\.cabal",
            ],
        ),
        (
            r"packages/[^/]+/main\.py",
            vec![
                r"packages/[^/]+/default\.nix",
                r"packages/[^/]+/static(/.*)?",
                r"packages/[^/]+/templates(/.*)?",
            ],
        ),
        (
            r"packages/[^/]+/main\.sh",
            vec![r"packages/[^/]+/default\.nix"],
        ),
    ];
    let compiled_names_allowed: Vec<Regex> = names_allowed
        .iter()
        .map(|p| Regex::new(&format!("^{}$", p)).unwrap())
        .collect();
    let compiled_file_dependencies: Vec<(Regex, Vec<Regex>)> = file_dependencies
        .iter()
        .map(|(trigger, patterns)| {
            (
                Regex::new(&format!("^{}$", trigger)).unwrap(),
                patterns
                    .iter()
                    .map(|p| Regex::new(&format!("^{}$", p)).unwrap())
                    .collect(),
            )
        })
        .collect();
    let mut allowed_patterns = compiled_names_allowed;
    for path in &dir_and_file_names {
        let path_str = path.to_str().unwrap();
        for (trigger_re, deps) in &compiled_file_dependencies {
            if trigger_re.is_match(path_str) {
                allowed_patterns.extend(deps.clone());
                allowed_patterns.push(trigger_re.clone());
            }
        }
    }
    let mut final_warnings = warnings;
    let mut sorted_names: Vec<_> = dir_and_file_names.into_iter().collect();
    sorted_names.sort();
    for name in sorted_names {
        let name_str = name.to_str().unwrap();
        if !allowed_patterns.iter().any(|re| re.is_match(name_str)) {
            if fix {
                let full_path = working_dir.join(&name);
                if full_path.is_file() {
                    std::fs::remove_file(&full_path).unwrap();
                } else if full_path.is_dir() {
                    std::fs::remove_dir_all(&full_path).unwrap();
                }
                println!("{}/{}: removed", working_dir.display(), name.display());
            } else {
                final_warnings.push(format!(
                    "{}/{}: is not allowed",
                    working_dir.display(),
                    name.display()
                ));
            }
        }
    }
    if !final_warnings.is_empty() {
        Err(final_warnings)
    } else {
        Ok(())
    }
}
fn run_tests() {
    test_is_valid_fqdn_standalone();
    test_is_dash_case_standalone();
    test_check_repository_directory_structure_standalone();
}
fn test_check_repository_directory_structure_standalone() {
    use std::fs;
    use std::process::Command;
    let temp_dir = std::env::temp_dir().join("test-repo-structure-standalone");
    if temp_dir.exists() {
        fs::remove_dir_all(&temp_dir).unwrap();
    }
    fs::create_dir_all(&temp_dir).unwrap();
    Command::new("git")
        .arg("init")
        .arg("-b")
        .arg("main")
        .current_dir(&temp_dir)
        .output()
        .expect("Failed to init git");
    Command::new("git")
        .args(["config", "user.email", "test@example.com"])
        .current_dir(&temp_dir)
        .output()
        .unwrap();
    Command::new("git")
        .args(["config", "user.name", "Test User"])
        .current_dir(&temp_dir)
        .output()
        .unwrap();
    fs::write(temp_dir.join("README"), "test").unwrap();
    Command::new("git")
        .arg("add")
        .arg("README")
        .current_dir(&temp_dir)
        .output()
        .expect("Failed to add README");
    Command::new("git")
        .arg("commit")
        .arg("-m")
        .arg("initial commit")
        .current_dir(&temp_dir)
        .output()
        .expect("Failed to commit");
    let result =
        check_repository_directory_structure(temp_dir.to_str().unwrap().to_string(), false);
    assert!(
        result.is_ok(),
        "Expected Ok, but got Err: {:?}",
        result.err()
    );
    fs::write(temp_dir.join("unallowed.txt"), "test").unwrap();
    let result =
        check_repository_directory_structure(temp_dir.to_str().unwrap().to_string(), false);
    assert!(result.is_err());
    fs::remove_dir_all(&temp_dir).unwrap();
    println!("test check_repository_directory_structure ... ok");
}
fn test_is_valid_fqdn_standalone() {
    assert!(is_valid_fqdn("google.com"));
    assert!(is_valid_fqdn("a.b.co"));
    assert!(!is_valid_fqdn("google"));
    assert!(!is_valid_fqdn("google."));
    assert!(!is_valid_fqdn(".com"));
    println!("test is_valid_fqdn ... ok");
}
fn test_is_dash_case_standalone() {
    assert!(is_dash_case("my-package"));
    assert!(is_dash_case("my.package"));
    assert!(is_dash_case("package123"));
    assert!(!is_dash_case("My-Package"));
    assert!(!is_dash_case("my_package"));
    println!("test is_dash_case ... ok");
}
#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn test_is_valid_fqdn() {
        assert!(is_valid_fqdn("google.com"));
        assert!(is_valid_fqdn("a.b.co"));
        assert!(!is_valid_fqdn("google"));
        assert!(!is_valid_fqdn("google."));
        assert!(!is_valid_fqdn(".com"));
    }
    #[test]
    fn test_is_dash_case() {
        assert!(is_dash_case("my-package"));
        assert!(is_dash_case("my.package"));
        assert!(is_dash_case("package123"));
        assert!(!is_dash_case("My-Package"));
        assert!(!is_dash_case("my_package"));
    }
    #[test]
    fn test_check_repository_directory_structure() {
        use std::fs;
        use std::process::Command;
        let temp_dir = std::env::temp_dir().join("test-repo-structure");
        if temp_dir.exists() {
            fs::remove_dir_all(&temp_dir).unwrap();
        }
        fs::create_dir_all(&temp_dir).unwrap();
        Command::new("git")
            .arg("init")
            .arg("-b")
            .arg("main")
            .current_dir(&temp_dir)
            .output()
            .expect("Failed to init git");
        Command::new("git")
            .args(["config", "user.email", "test@example.com"])
            .current_dir(&temp_dir)
            .output()
            .unwrap();
        Command::new("git")
            .args(["config", "user.name", "Test User"])
            .current_dir(&temp_dir)
            .output()
            .unwrap();
        fs::write(temp_dir.join("README"), "test").unwrap();
        Command::new("git")
            .arg("add")
            .arg("README")
            .current_dir(&temp_dir)
            .output()
            .expect("Failed to add README");
        Command::new("git")
            .arg("commit")
            .arg("-m")
            .arg("initial commit")
            .current_dir(&temp_dir)
            .output()
            .expect("Failed to commit");
        let result =
            check_repository_directory_structure(temp_dir.to_str().unwrap().to_string(), false);
        assert!(
            result.is_ok(),
            "Expected Ok, but got Err: {:?}",
            result.err()
        );
        fs::write(temp_dir.join("unallowed.txt"), "test").unwrap();
        let result =
            check_repository_directory_structure(temp_dir.to_str().unwrap().to_string(), false);
        assert!(result.is_err());
        fs::remove_dir_all(&temp_dir).unwrap();
    }
}
