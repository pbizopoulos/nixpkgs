#![allow(clippy::multiple_crate_versions)]
#![allow(clippy::too_many_lines)]
#![allow(clippy::needless_pass_by_value)]
use clap::Parser;
use git2::{Repository, StatusOptions};
use regex::Regex;
use std::collections::HashSet;
use std::path::{Path, PathBuf};
use walkdir::WalkDir;
#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
struct Args {
    #[arg(default_value = "flake.nix")]
    flake_nix_path: String,
}
fn is_valid_fqdn(name: &str) -> bool {
    let re = Regex::new(r"^([a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,}$").unwrap();
    re.is_match(name)
}
fn is_dash_case(name: &str) -> bool {
    let re = Regex::new(r"^[a-z0-9]+([-.][a-z0-9]+)*$").unwrap();
    re.is_match(name)
}
fn package_root(rel_path: &Path) -> Option<PathBuf> {
    let components: Vec<_> = rel_path
        .components()
        .map(|component| component.as_os_str().to_str().unwrap())
        .collect();
    match components.as_slice() {
        ["packages", package_name, ..] => Some(PathBuf::from(format!("packages/{package_name}"))),
        ["templates", template_name, "packages", package_name, ..] => Some(PathBuf::from(format!(
            "templates/{template_name}/packages/{package_name}"
        ))),
        _ => None,
    }
}
fn host_root(rel_path: &Path) -> Option<PathBuf> {
    let components: Vec<_> = rel_path
        .components()
        .map(|component| component.as_os_str().to_str().unwrap())
        .collect();
    match components.as_slice() {
        ["hosts", host_name, ..] => Some(PathBuf::from(format!("hosts/{host_name}"))),
        _ => None,
    }
}
fn validate_adonis_package_layout(
    working_dir: &Path,
    package_root: &Path,
    dir_and_file_names: &HashSet<PathBuf>,
) -> Vec<String> {
    let allowed_patterns = [
        r"^\.adonisjs/client/.*$",
        r"^\.adonisjs/server/.*\.(d\.)?ts$",
        r"^\.dependency-cruiser\.cjs$",
        r"^\.env$",
        r"^\.env\.example$",
        r"^\.gitignore$",
        r"^\.jscpd\.json$",
        r"^ace\.js$",
        r"^adonisrc\.ts$",
        r"^app/controllers/.*\.ts$",
        r"^app/exceptions/.*\.ts$",
        r"^app/mails/(\.gitkeep|.*\.ts)$",
        r"^app/middleware/.*\.ts$",
        r"^app/models/.*\.ts$",
        r"^app/transformers/.*\.ts$",
        r"^app/validators/.*\.ts$",
        r"^bin/.*\.(js|sh|ts)$",
        r"^config/.*\.ts$",
        r"^database/.*\.ts$",
        r"^default\.nix$",
        r"^eslint\.config\.js$",
        r"^package-lock\.json$",
        r"^package\.json$",
        r"^playwright\.config\.ts$",
        r"^providers/.*\.ts$",
        r"^public/.*$",
        r"^resources/css/.*\.css$",
        r"^resources/js/.*\.js$",
        r"^resources/views(/.*)?$",
        r"^spec\.json$",
        r"^start/.*\.ts$",
        r"^stryker\.config\.mjs$",
        r"^tests/bootstrap\.ts$",
        r"^tests/browser/.*\.ts$",
        r"^tests/functional/.*\.ts$",
        r"^tests/unit/.*\.ts$",
        r"^tmp/\.gitignore$",
        r"^tsconfig\.json$",
        r"^vite\.config\.ts$",
    ]
    .iter()
    .map(|pattern| Regex::new(pattern).unwrap())
    .collect::<Vec<_>>();
    let mut warnings = Vec::new();
    for path in dir_and_file_names {
        let Ok(package_relative_path) = path.strip_prefix(package_root) else {
            continue;
        };
        let package_relative_path = package_relative_path.to_str().unwrap();
        if !allowed_patterns
            .iter()
            .any(|pattern| pattern.is_match(package_relative_path))
        {
            warnings.push(format!(
                "{}: is not allowed for an AdonisJS template package",
                working_dir.join(path).display()
            ));
        }
    }
    warnings
}
use std::time::{SystemTime, UNIX_EPOCH};
fn main() {
    let args = Args::parse();
    let flake_nix_path = args.flake_nix_path;
    let lock_path = std::env::temp_dir().join("check_repository_directory_structure.lock");
    let lock_file = std::fs::OpenOptions::new()
        .read(true)
        .write(true)
        .create(true)
        .truncate(false)
        .open(&lock_path)
        .expect("Failed to open lock file");
    let mut lock = fd_lock::RwLock::new(lock_file);
    let mut _guard = lock.write().expect("Failed to acquire write lock");
    let now = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_secs();
    let last_run_str = std::fs::read_to_string(&lock_path).unwrap_or_default();
    let last_run: u64 = last_run_str.trim().parse().unwrap_or(0);
    if now - last_run < 5 {
        std::process::exit(0);
    }
    match check_repository_directory_structure(flake_nix_path) {
        #[allow(clippy::ignored_unit_patterns)]
        Ok(()) => {
            std::fs::write(&lock_path, now.to_string()).unwrap();
            std::process::exit(0)
        }
        Err(warnings) => {
            println!("{}", warnings.join("\n"));
            std::process::exit(1);
        }
    }
}
fn check_repository_directory_structure(flake_nix_path: String) -> Result<(), Vec<String>> {
    if std::env::var("NIX_BUILD_TOP").is_ok() {
        return Ok(());
    }
    let mut warnings = Vec::new();
    let dir_path = Path::new(&flake_nix_path)
        .canonicalize()
        .expect("Failed to canonicalize path");
    let Ok(repo) = Repository::discover(&dir_path) else {
        return Ok(());
    };
    let working_dir = repo.workdir().expect("No working directory for repository");
    let working_dir_display = working_dir.display();
    let mut status_options = StatusOptions::new();
    status_options.include_untracked(true);
    let statuses = match repo.statuses(Some(&mut status_options)) {
        Ok(s) => s,
        Err(_) => return Ok(()),
    };
    for entry in statuses.iter() {
        if entry.status().is_wt_new() {
            warnings.push(format!(
                "{}: is untracked",
                working_dir.join(entry.path().unwrap()).display()
            ));
        }
    }
    let head = repo.head();
    if let Ok(head) = head {
        let branch_name = head.shorthand().expect("Failed to get branch name");
        if branch_name != "main" {
            warnings.push(format!(
                "{working_dir_display}: should have 'main' as the active branch"
            ));
        }
        let branches = repo
            .branches(Some(git2::BranchType::Local))
            .expect("Failed to get branches");
        if branches.count() != 1 {
            warnings.push(format!(
                "{working_dir_display}: should have only one branch"
            ));
        }
    }
    let dir_name_str = working_dir.file_name().unwrap().to_str().unwrap();
    if dir_name_str != dir_name_str.to_lowercase()
        || (!is_valid_fqdn(dir_name_str) && !is_dash_case(dir_name_str))
    {
        warnings.push(format!(
            "{working_dir_display}: should be lower-case and valid FQDN or in dash-case"
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
            if s == "tmp"
                || s == "prm"
                || s == "target"
                || s == "CSharpier"
                || s == ".adonisjs"
                || s == "build"
                || s == "coverage"
                || s == "_build"
                || s == "deps"
                || s == "node_modules"
                || s == ".nuxt"
                || s == ".svelte-kit"
                || s == ".stryker-tmp"
                || s == "reports"
                || s == "result"
                || s == "test-results"
                || s == "tsconfig.tsbuildinfo"
            {
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
    let all_rel_paths: HashSet<_> = paths
        .iter()
        .map(|path| path.strip_prefix(working_dir).unwrap().to_path_buf())
        .collect();
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
        r"hosts/[^/]+/configuration\.nix",
        r"hosts/[^/]+/hardware-configuration\.nix",
        r"modules/nixos/.*",
        r"packages/[^/]+/\.gitignore",
        r"packages/[^/]+/Main\.hs",
        r"packages/[^/]+/Cargo\.toml",
        r"packages/[^/]+/default\.nix",
        r"packages/[^/]+/index\.html",
        r"packages/[^/]+/main\.(c|py|sh|tf)",
        r"packages/[^/]+/ms\.tex",
        r"packages/[^/]+/package\.json",
        r"packages/[^/]+/spec\.json",
        r"packages/[^/]+/style\.css",
        r"packages/[^/]+/script\.js",
        r"packages/[^/]+/[^/]+\.cabal",
        r"prm(/.*)?",
        r"result",
        r"secrets(/.*)?",
        r"spec\.json",
    ];
    let file_dependencies = [
        (
            r"packages/[^/]+/Cargo\.toml",
            vec![r"packages/[^/]+/Cargo\.lock", r"packages/[^/]+/src/.*"],
        ),
        (
            r"packages/[^/]+/Main\.hs",
            vec![r"packages/[^/]+/[^/]+\.cabal"],
        ),
        (
            r"packages/[^/]+/index\.html",
            vec![r"packages/[^/]+/script\.js", r"packages/[^/]+/style\.css"],
        ),
        (
            r"packages/[^/]+/main\.tf",
            vec![
                r"packages/[^/]+/\.gitignore",
                r"packages/[^/]+/\.terraform(/.*)?",
                r"packages/[^/]+/\.terraform\.lock\.hcl",
                r"packages/[^/]+/prm/.*",
            ],
        ),
        (r"packages/[^/]+/ms\.tex", vec![r"packages/[^/]+/ms\.bib"]),
        (
            r"packages/[^/]+/package\.json",
            vec![
                r"packages/[^/]+/\.adonisjs/.*",
                r"packages/[^/]+/\.dependency-cruiser\.cjs",
                r"packages/[^/]+/\.env",
                r"packages/[^/]+/\.env\.example",
                r"packages/[^/]+/\.jscpd\.json",
                r"packages/[^/]+/ace\.js",
                r"packages/[^/]+/adonisrc\.ts",
                r"packages/[^/]+/app/.*",
                r"packages/[^/]+/bin/.*",
                r"packages/[^/]+/config/.*",
                r"packages/[^/]+/coverage(/.*)?",
                r"packages/[^/]+/database/.*",
                r"packages/[^/]+/eslint\.config\.js",
                r"packages/[^/]+/package-lock\.json",
                r"packages/[^/]+/playwright\.config\.ts",
                r"packages/[^/]+/providers/.*",
                r"packages/[^/]+/public/.*",
                r"packages/[^/]+/resources/.*",
                r"packages/[^/]+/commands/.*",
                r"packages/[^/]+/start/.*",
                r"packages/[^/]+/stryker\.config\.mjs",
                r"packages/[^/]+/test-results(/.*)?",
                r"packages/[^/]+/tests/.*",
                r"packages/[^/]+/tsconfig\.json",
                r"packages/[^/]+/tsconfig\.tsbuildinfo",
                r"packages/[^/]+/vite\.config\.ts",
                r"packages/[^/]+/vitest\.config\.ts",
            ],
        ),
    ];
    let prefix = r"(templates/[^/]+/)?";
    let compiled_names_allowed: Vec<Regex> = names_allowed
        .iter()
        .map(|p| Regex::new(&format!("^{prefix}{p}$")).unwrap())
        .collect();
    let compiled_file_dependencies: Vec<(Regex, Vec<String>)> = file_dependencies
        .iter()
        .map(|(trigger, patterns)| {
            (
                Regex::new(&format!("^{prefix}({trigger})$")).unwrap(),
                patterns
                    .iter()
                    .map(std::string::ToString::to_string)
                    .collect(),
            )
        })
        .collect();
    let mut allowed_patterns = compiled_names_allowed;
    for path in &dir_and_file_names {
        let path_str = path.to_str().unwrap();
        for (trigger_re, deps) in &compiled_file_dependencies {
            if let Some(caps) = trigger_re.captures(path_str) {
                let captured_prefix = caps.get(1).map_or("", |m| m.as_str());
                for dep in deps {
                    let full_dep = format!("^{captured_prefix}{dep}$");
                    allowed_patterns.push(Regex::new(&full_dep).unwrap());
                }
                allowed_patterns.push(trigger_re.clone());
            }
        }
    }
    let mut final_warnings = warnings;
    let package_roots: HashSet<_> = all_rel_paths
        .iter()
        .filter_map(|path| package_root(path))
        .collect();
    for package_root in &package_roots {
        let default_nix = package_root.join("default.nix");
        if !all_rel_paths.contains(&default_nix) {
            final_warnings.push(format!(
                "{}: is missing required default.nix",
                working_dir.join(package_root).display()
            ));
        }
    }
    let host_roots: HashSet<_> = all_rel_paths
        .iter()
        .filter_map(|path| host_root(path))
        .collect();
    for host_root in host_roots {
        let configuration_nix = host_root.join("configuration.nix");
        if !all_rel_paths.contains(&configuration_nix) {
            final_warnings.push(format!(
                "{}: is missing required configuration.nix",
                working_dir.join(host_root).display()
            ));
        }
    }
    for package_root in &package_roots {
        if all_rel_paths.contains(&package_root.join("adonisrc.ts")) {
            final_warnings.extend(validate_adonis_package_layout(
                working_dir,
                package_root,
                &dir_and_file_names,
            ));
        }
    }
    let mut sorted_names: Vec<_> = dir_and_file_names.into_iter().collect();
    sorted_names.sort();
    for name in sorted_names {
        let name_str = name.to_str().unwrap();
        if !allowed_patterns.iter().any(|re| re.is_match(name_str)) {
            if std::env::var("DEBUG").as_deref() == Ok("1") {
                for re in &allowed_patterns {
                    eprintln!("Pattern: {}", re.as_str());
                }
            }
            final_warnings.push(format!(
                "{}: is not allowed",
                working_dir.join(name).display()
            ));
        }
    }
    if final_warnings.is_empty() {
        Ok(())
    } else {
        Err(final_warnings)
    }
}
#[allow(dead_code)]
fn run_tests() {
    test_is_valid_fqdn_standalone();
    test_is_dash_case_standalone();
    test_check_repository_directory_structure_standalone();
}
fn test_check_repository_directory_structure_standalone() {
    std::env::remove_var("NIX_BUILD_TOP");
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
    fs::write(temp_dir.join("flake.nix"), "test").unwrap();
    Command::new("git")
        .arg("add")
        .arg("flake.nix")
        .current_dir(&temp_dir)
        .output()
        .expect("Failed to add flake.nix");
    Command::new("git")
        .arg("commit")
        .arg("-m")
        .arg("initial commit")
        .current_dir(&temp_dir)
        .output()
        .expect("Failed to commit");
    let flake_nix_path = temp_dir.join("flake.nix");
    let result = check_repository_directory_structure(flake_nix_path.to_str().unwrap().to_string());
    assert!(
        result.is_ok(),
        "Expected Ok, but got Err: {:?}",
        result.err()
    );
    fs::write(temp_dir.join("unallowed.txt"), "test").unwrap();
    let result = check_repository_directory_structure(flake_nix_path.to_str().unwrap().to_string());
    assert!(result.is_err());
    fs::remove_file(temp_dir.join("unallowed.txt")).unwrap();
    fs::create_dir_all(temp_dir.join("templates/my-template/packages/my-pkg/app/exceptions"))
        .unwrap();
    fs::create_dir_all(temp_dir.join("templates/my-template/packages/my-pkg/public/styles"))
        .unwrap();
    fs::create_dir_all(temp_dir.join("templates/my-template/packages/my-pkg/tests/e2e")).unwrap();
    fs::write(
        temp_dir.join("templates/my-template/packages/my-pkg/default.nix"),
        "test",
    )
    .unwrap();
    fs::write(
        temp_dir.join("templates/my-template/packages/my-pkg/package.json"),
        "test",
    )
    .unwrap();
    fs::write(
        temp_dir.join("templates/my-template/packages/my-pkg/.env.example"),
        "test",
    )
    .unwrap();
    fs::write(
        temp_dir.join("templates/my-template/packages/my-pkg/app/exceptions/handler.ts"),
        "test",
    )
    .unwrap();
    fs::write(
        temp_dir.join("templates/my-template/packages/my-pkg/public/styles/app.css"),
        "test",
    )
    .unwrap();
    Command::new("git")
        .args(["add", "templates"])
        .current_dir(&temp_dir)
        .output()
        .unwrap();
    let result = check_repository_directory_structure(flake_nix_path.to_str().unwrap().to_string());
    assert!(
        result.is_ok(),
        "Expected Ok for templates, but got Err: {:?}",
        result.err()
    );
    fs::write(
        temp_dir.join("templates/my-template/packages/my-pkg/unallowed.txt"),
        "test",
    )
    .unwrap();
    let result = check_repository_directory_structure(flake_nix_path.to_str().unwrap().to_string());
    assert!(result.is_err());
    fs::remove_file(temp_dir.join("templates/my-template/packages/my-pkg/unallowed.txt")).unwrap();
    fs::write(
        temp_dir.join("templates/my-template/packages/my-pkg/package.json"),
        "test",
    )
    .unwrap();
    fs::create_dir_all(temp_dir.join("templates/my-template/packages/my-pkg/tests")).unwrap();
    fs::write(
        temp_dir.join("templates/my-template/packages/my-pkg/tests/test.ts"),
        "test",
    )
    .unwrap();
    Command::new("git")
        .args(["add", "templates"])
        .current_dir(&temp_dir)
        .output()
        .unwrap();
    let result = check_repository_directory_structure(flake_nix_path.to_str().unwrap().to_string());
    assert!(
        result.is_ok(),
        "Expected Ok for package.json tests, but got Err: {:?}",
        result.err()
    );
    fs::create_dir_all(temp_dir.join("packages/no-default")).unwrap();
    fs::write(temp_dir.join("packages/no-default/main.py"), "test").unwrap();
    let result = check_repository_directory_structure(flake_nix_path.to_str().unwrap().to_string());
    assert!(result.is_err());
    fs::remove_dir_all(temp_dir.join("packages/no-default")).unwrap();
    fs::remove_dir(temp_dir.join("packages")).unwrap();
    fs::create_dir_all(temp_dir.join("hosts/my-host")).unwrap();
    fs::write(temp_dir.join("hosts/my-host/configuration.nix"), "test").unwrap();
    fs::write(
        temp_dir.join("hosts/my-host/hardware-configuration.nix"),
        "test",
    )
    .unwrap();
    Command::new("git")
        .args(["add", "hosts"])
        .current_dir(&temp_dir)
        .output()
        .unwrap();
    let result = check_repository_directory_structure(flake_nix_path.to_str().unwrap().to_string());
    assert!(
        result.is_ok(),
        "Expected Ok for hosts/configuration.nix, but got Err: {:?}",
        result.err()
    );
    fs::write(temp_dir.join("hosts/my-host/.gitignore"), "test").unwrap();
    let result = check_repository_directory_structure(flake_nix_path.to_str().unwrap().to_string());
    assert!(result.is_err());
    fs::remove_file(temp_dir.join("hosts/my-host/.gitignore")).unwrap();
    fs::create_dir_all(temp_dir.join("hosts/only-hardware")).unwrap();
    fs::write(
        temp_dir.join("hosts/only-hardware/hardware-configuration.nix"),
        "test",
    )
    .unwrap();
    let result = check_repository_directory_structure(flake_nix_path.to_str().unwrap().to_string());
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
    use std::fs;
    use std::path::Path;
    use std::process::Command;
    fn init_temp_repo(path: &Path) {
        if path.exists() {
            fs::remove_dir_all(path).unwrap();
        }
        fs::create_dir_all(path).unwrap();
        Command::new("git")
            .arg("init")
            .arg("-b")
            .arg("main")
            .current_dir(path)
            .output()
            .expect("Failed to init git");
        Command::new("git")
            .args(["config", "user.email", "test@example.com"])
            .current_dir(path)
            .output()
            .unwrap();
        Command::new("git")
            .args(["config", "user.name", "Test User"])
            .current_dir(path)
            .output()
            .unwrap();
        fs::write(path.join("flake.nix"), "test").unwrap();
        Command::new("git")
            .arg("add")
            .arg("flake.nix")
            .current_dir(path)
            .output()
            .expect("Failed to add flake.nix");
        Command::new("git")
            .arg("commit")
            .arg("-m")
            .arg("initial commit")
            .current_dir(path)
            .output()
            .expect("Failed to commit");
    }
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
    fn test_package_root() {
        assert_eq!(
            package_root(Path::new("packages/adonisjs_template/package.json")),
            Some(PathBuf::from("packages/adonisjs_template"))
        );
        assert_eq!(
            package_root(Path::new(
                "templates/example/packages/adonisjs_template/package.json"
            )),
            Some(PathBuf::from(
                "templates/example/packages/adonisjs_template"
            ))
        );
        assert_eq!(
            package_root(Path::new("hosts/adonisjs_template/configuration.nix")),
            None
        );
    }
    #[test]
    fn test_host_root() {
        assert_eq!(
            host_root(Path::new("hosts/adonisjs_template/configuration.nix")),
            Some(PathBuf::from("hosts/adonisjs_template"))
        );
        assert_eq!(
            host_root(Path::new("packages/adonisjs_template/default.nix")),
            None
        );
    }
    #[test]
    fn test_validate_adonis_package_layout_rejects_legacy_scripts() {
        let working_dir = Path::new("/tmp/repo");
        let package_root = Path::new("packages/adonisjs_template");
        let dir_and_file_names = HashSet::from([
            PathBuf::from("packages/adonisjs_template/bin/entrypoint.js"),
            PathBuf::from("packages/adonisjs_template/scripts/test-ci.sh"),
            PathBuf::from("packages/adonisjs_template/resources/views/errors"),
            PathBuf::from("packages/adonisjs_template/database/schema.ts"),
        ]);
        let warnings =
            validate_adonis_package_layout(working_dir, package_root, &dir_and_file_names);
        assert_eq!(warnings.len(), 1);
        assert!(warnings[0].contains("packages/adonisjs_template/scripts/test-ci.sh"));
    }
    #[test]
    fn test_validate_adonis_package_layout_ignores_other_packages() {
        let working_dir = Path::new("/tmp/repo");
        let package_root = Path::new("packages/adonisjs_template");
        let dir_and_file_names = HashSet::from([PathBuf::from("packages/python_template/main.py")]);
        let warnings =
            validate_adonis_package_layout(working_dir, package_root, &dir_and_file_names);
        assert!(warnings.is_empty());
    }
    #[test]
    fn test_check_repository_directory_structure() {
        std::env::remove_var("NIX_BUILD_TOP");
        let temp_dir = std::env::temp_dir().join("test-repo-structure");
        init_temp_repo(&temp_dir);
        let flake_nix_path = temp_dir.join("flake.nix");
        let result =
            check_repository_directory_structure(flake_nix_path.to_str().unwrap().to_string());
        assert!(
            result.is_ok(),
            "Expected Ok, but got Err: {:?}",
            result.err()
        );
        fs::write(temp_dir.join("unallowed.txt"), "test").unwrap();
        let result =
            check_repository_directory_structure(flake_nix_path.to_str().unwrap().to_string());
        assert!(result.is_err());
        fs::remove_file(temp_dir.join("unallowed.txt")).unwrap();
        fs::create_dir_all(temp_dir.join("templates/my-template/packages/my-pkg/config")).unwrap();
        fs::write(
            temp_dir.join("templates/my-template/packages/my-pkg/default.nix"),
            "test",
        )
        .unwrap();
        fs::write(
            temp_dir.join("templates/my-template/packages/my-pkg/package.json"),
            "test",
        )
        .unwrap();
        fs::write(
            temp_dir.join("templates/my-template/packages/my-pkg/.gitignore"),
            "test",
        )
        .unwrap();
        fs::write(
            temp_dir.join("templates/my-template/packages/my-pkg/config/app.ts"),
            "test",
        )
        .unwrap();
        Command::new("git")
            .args(["add", "templates"])
            .current_dir(&temp_dir)
            .output()
            .unwrap();
        let result =
            check_repository_directory_structure(flake_nix_path.to_str().unwrap().to_string());
        assert!(
            result.is_ok(),
            "Expected Ok for templates, but got Err: {:?}",
            result.err()
        );
        fs::create_dir_all(temp_dir.join("packages/no-default")).unwrap();
        fs::write(temp_dir.join("packages/no-default/main.py"), "test").unwrap();
        let result =
            check_repository_directory_structure(flake_nix_path.to_str().unwrap().to_string());
        assert!(result.is_err());
        fs::remove_dir_all(temp_dir.join("packages/no-default")).unwrap();
        fs::remove_dir(temp_dir.join("packages")).unwrap();
        fs::create_dir_all(temp_dir.join("hosts/my-host")).unwrap();
        fs::write(temp_dir.join("hosts/my-host/configuration.nix"), "test").unwrap();
        fs::write(
            temp_dir.join("hosts/my-host/hardware-configuration.nix"),
            "test",
        )
        .unwrap();
        Command::new("git")
            .args(["add", "hosts"])
            .current_dir(&temp_dir)
            .output()
            .unwrap();
        let result =
            check_repository_directory_structure(flake_nix_path.to_str().unwrap().to_string());
        assert!(
            result.is_ok(),
            "Expected Ok for hosts/configuration.nix, but got Err: {:?}",
            result.err()
        );
        fs::write(temp_dir.join("hosts/my-host/.gitignore"), "test").unwrap();
        let result =
            check_repository_directory_structure(flake_nix_path.to_str().unwrap().to_string());
        assert!(result.is_err());
        fs::remove_file(temp_dir.join("hosts/my-host/.gitignore")).unwrap();
        fs::create_dir_all(temp_dir.join("hosts/only-hardware")).unwrap();
        fs::write(
            temp_dir.join("hosts/only-hardware/hardware-configuration.nix"),
            "test",
        )
        .unwrap();
        let result =
            check_repository_directory_structure(flake_nix_path.to_str().unwrap().to_string());
        assert!(result.is_err());
        fs::remove_dir_all(&temp_dir).unwrap();
    }
    #[test]
    fn test_adonis_package_layout_matches_repository_conventions() {
        std::env::remove_var("NIX_BUILD_TOP");
        let temp_dir = std::env::temp_dir().join("test-repo-structure-adonis");
        init_temp_repo(&temp_dir);
        let package_root = temp_dir.join("packages/adonisjs_template");
        for relative_dir in [
            ".adonisjs/client",
            ".adonisjs/server",
            "app/controllers",
            "app/exceptions",
            "app/mails",
            "app/middleware",
            "app/models",
            "app/transformers",
            "app/validators",
            "bin",
            "config",
            "database/factories",
            "database/migrations",
            "database/seeders",
            "providers",
            "public",
            "resources/css",
            "resources/js",
            "resources/views/auth",
            "resources/views/emails",
            "resources/views/errors",
            "start",
            "tests/functional/browser",
            "tests/unit",
            "tmp",
        ] {
            fs::create_dir_all(package_root.join(relative_dir)).unwrap();
        }
        for (relative_path, contents) in [
            (".dependency-cruiser.cjs", "module.exports = {};"),
            (".env", "PORT=3333\n"),
            (".env.example", "PORT=3333\n"),
            (".gitignore", "tmp/\n"),
            (".jscpd.json", "{}"),
            ("ace.js", "console.log('ace');"),
            ("adonisrc.ts", "export default {};"),
            (".adonisjs/client/types.ts", "export type App = {};"),
            (".adonisjs/server/routes.d.ts", "export {};"),
            (
                "app/controllers/home_controller.ts",
                "export default class HomeController {}",
            ),
            (
                "app/exceptions/handler.ts",
                "export default class Handler {}",
            ),
            ("app/mails/.gitkeep", ""),
            (
                "app/middleware/auth_middleware.ts",
                "export default class AuthMiddleware {}",
            ),
            ("app/models/user.ts", "export default class User {}"),
            (
                "app/transformers/user_transformer.ts",
                "export const userTransformer = {};",
            ),
            ("app/validators/auth.ts", "export const authValidator = {};"),
            ("bin/console.ts", "export {};"),
            ("bin/entrypoint.js", "console.log('entrypoint');"),
            ("bin/pg.sh", "#!/usr/bin/env sh\n"),
            ("bin/server.ts", "export {};"),
            ("bin/test-ci.sh", "#!/usr/bin/env sh\n"),
            ("bin/test.ts", "export {};"),
            ("config/app.ts", "export default {};"),
            ("database/factories/user_factory.ts", "export default {};"),
            (
                "database/migrations/000_create_users_table.ts",
                "export default {};",
            ),
            ("database/schema.ts", "export class UserSchema {}"),
            (
                "database/schema_rules.ts",
                "export const usernameSchemaRules = {};",
            ),
            ("database/seeders/user_seeder.ts", "export default {};"),
            ("default.nix", "{}"),
            ("eslint.config.js", "export default [];"),
            ("package-lock.json", "{}"),
            ("package.json", "{\"name\":\"adonisjs_template\"}"),
            ("playwright.config.ts", "export default {};"),
            (
                "providers/app_provider.ts",
                "export default class AppProvider {}",
            ),
            ("public/robots.txt", "User-agent: *\n"),
            ("resources/css/app.css", "body {}\n"),
            ("resources/js/app.js", "console.log('app');"),
            ("resources/views/auth/login.edge", ""),
            ("resources/views/emails/welcome.edge", ""),
            ("resources/views/errors/404.edge", ""),
            ("resources/views/home.edge", ""),
            ("spec.json", "{}"),
            ("start/env.ts", "export {};"),
            ("start/kernel.ts", "export {};"),
            ("start/routes.ts", "export {};"),
            ("stryker.config.mjs", "export default {};"),
            ("tests/bootstrap.ts", "export {};"),
            ("tests/functional/browser/app.spec.ts", "export {};"),
            ("tests/unit/username.test.ts", "export {};"),
            ("tmp/.gitignore", "*\n"),
            ("tsconfig.json", "{}"),
            ("vite.config.ts", "export default {};"),
        ] {
            fs::write(package_root.join(relative_path), contents).unwrap();
        }
        Command::new("git")
            .args(["add", "packages"])
            .current_dir(&temp_dir)
            .output()
            .unwrap();
        let flake_nix_path = temp_dir.join("flake.nix");
        let result =
            check_repository_directory_structure(flake_nix_path.to_str().unwrap().to_string());
        assert!(
            result.is_ok(),
            "Expected Ok for the current AdonisJS package layout, but got Err: {:?}",
            result.err()
        );
        fs::create_dir_all(package_root.join("scripts")).unwrap();
        fs::write(
            package_root.join("scripts/test-ci.sh"),
            "#!/usr/bin/env sh\n",
        )
        .unwrap();
        let result =
            check_repository_directory_structure(flake_nix_path.to_str().unwrap().to_string());
        assert!(
            result.is_err(),
            "Expected Err for legacy scripts/ layout, but got Ok",
        );
        fs::remove_dir_all(&temp_dir).unwrap();
    }
}
