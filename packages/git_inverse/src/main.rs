use anyhow::{Context, Result};
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

struct GitIgnoreGuard {
    repo_root: PathBuf,
    temp_path: PathBuf,
    original_exists: bool,
}

fn move_file(from: &Path, to: &Path) -> Result<()> {
    if let Err(e) = fs::rename(from, to) {
        if e.raw_os_error() == Some(18) {
            // Cross-device link (EXDEV), fallback to copy + remove
            fs::copy(from, to)
                .with_context(|| format!("Failed to copy {:?} to {:?}", from, to))?;
            fs::remove_file(from)
                .with_context(|| format!("Failed to remove source file {:?}", from))?;
        } else {
            return Err(anyhow::Error::from(e))
                .with_context(|| format!("Failed to move {:?} to {:?}", from, to));
        }
    }
    Ok(())
}

impl GitIgnoreGuard {
    fn new(repo_root: PathBuf) -> Result<Self> {
        let gitignore_path = repo_root.join(".gitignore");
        let temp_path = std::env::temp_dir().join(format!(".gitignore.{}.orig", std::process::id()));
        let original_exists = gitignore_path.exists();

        if original_exists {
            move_file(&gitignore_path, &temp_path)?;
        }

        Ok(Self {
            repo_root,
            temp_path,
            original_exists,
        })
    }
}

impl Drop for GitIgnoreGuard {
    fn drop(&mut self) {
        let gitignore_path = self.repo_root.join(".gitignore");
        if self.original_exists {
            if let Err(e) = move_file(&self.temp_path, &gitignore_path) {
                eprintln!("Error: Failed to restore .gitignore: {}", e);
            }
        } else if gitignore_path.exists() {
            if let Err(e) = fs::remove_file(&gitignore_path) {
                eprintln!("Error: Failed to remove temporary .gitignore: {}", e);
            }
        }
    }
}

fn get_repo_root() -> PathBuf {
    let output = Command::new("git")
        .args(["rev-parse", "--show-toplevel"])
        .output();

    match output {
        Ok(out) if out.status.success() => {
            let path_str = String::from_utf8_lossy(&out.stdout).trim().to_string();
            PathBuf::from(path_str)
        }
        _ => std::env::current_dir().unwrap_or_else(|_| PathBuf::from(".")),
    }
}

fn run_tests() -> Result<()> {
    println!("Running tests...");
    
    let root = get_repo_root();
    assert!(root.exists());
    println!("test get_repo_root ... ok");

    let temp_dir = std::env::temp_dir().join(format!("git_inverse_test_{}", std::process::id()));
    fs::create_dir_all(&temp_dir)?;
    
    let gitignore = temp_dir.join(".gitignore");
    fs::write(&gitignore, "test-content")?;
    
    {
        let _guard = GitIgnoreGuard::new(temp_dir.clone())?;
        assert!(!gitignore.exists());
    }
    
    assert!(gitignore.exists());
    assert_eq!(fs::read_to_string(&gitignore)?, "test-content");
    
    fs::remove_dir_all(&temp_dir)?;
    println!("test git_ignore_guard ... ok");

    println!("All tests passed!");
    Ok(())
}

fn run() -> Result<i32> {
    if std::env::var("DEBUG").as_deref() == Ok("1") {
        run_tests()?;
        return Ok(0);
    }

    let args: Vec<String> = std::env::args().collect();
    if args.len() > 1 && (args[1] == "-h" || args[1] == "--help" || args[1] == "help") {
        println!("git-inverse: track files ignored by the main Git repository");
        println!("Usage:");
        println!("  git-inverse <git-command> [args...]");
        println!("Runs Git commands in the inverse repository (.gitinverse), which tracks");
        println!("only files ignored by the main repository. Temporarily inverts .gitignore");
        println!("rules so normally ignored files become trackable.");
        return Ok(0);
    }

    let repo_root = get_repo_root();
    let gitinverse_dir = repo_root.join(".gitinverse");

    if gitinverse_dir.is_dir() {
        fs::write(gitinverse_dir.join(".gitignore"), "*")?;

        let ls_files = Command::new("git")
            .args(["-C", repo_root.to_str().unwrap(), "ls-files", repo_root.to_str().unwrap()])
            .output()?;
        
        fs::write(gitinverse_dir.join("info/exclude"), ls_files.stdout)?;

        let git_dir = gitinverse_dir.to_str().unwrap();
        let work_tree = repo_root.to_str().unwrap();

        Command::new("git")
            .args(["--git-dir", git_dir, "--work-tree", work_tree, "config", "diff.tool", "imagemagick"])
            .status()?;

        Command::new("git")
            .args([
                "--git-dir", git_dir,
                "--work-tree", work_tree,
                "config",
                "difftool.imagemagick.cmd",
                "compare \"$LOCAL\" \"$REMOTE\" \"$LOCAL-diff.png\""
            ])
            .status()?;
    } else {
        eprintln!("Error: .gitinverse directory not found in {}", repo_root.display());
        eprintln!("Please initialize it first with: git init --separate-git-dir=.gitinverse");
        return Ok(1);
    }

    let _guard = GitIgnoreGuard::new(repo_root.clone())?;

    let git_dir_arg = gitinverse_dir.to_str().context("Failed to convert gitinverse_dir to string")?;
    let work_tree_arg = repo_root.to_str().context("Failed to convert repo_root to string")?;

    let mut git_cmd = Command::new("git");
    git_cmd.args(["--git-dir", git_dir_arg, "--work-tree", work_tree_arg]);
    
    if args.len() > 1 {
        git_cmd.args(&args[1..]);
    } else {
        git_cmd.arg("status");
    }

    let status = git_cmd.status()?;
    Ok(status.code().unwrap_or(1))
}

fn main() {
    match run() {
        Ok(code) => std::process::exit(code),
        Err(e) => {
            eprintln!("Error: {:?}", e);
            std::process::exit(1);
        }
    }
}
