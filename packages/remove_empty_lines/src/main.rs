use anyhow::{Context, Result};
use ignore::WalkBuilder;
use std::fs;
use std::io::{BufRead, BufReader, Write};
use std::path::Path;

fn main() -> Result<()> {
    if std::env::var("DEBUG").as_deref() == Ok("1") {
        run_tests()?;
    } else {
        process_repo(Path::new("."))?;
    }
    Ok(())
}

fn process_repo(root: &Path) -> Result<()> {
    // Set require_git(false) so it works even if we are not in a git repo
    // (e.g. in tests or source tarballs with .gitignore)
    let walker = WalkBuilder::new(root).require_git(false).build();

    for result in walker {
        match result {
            Ok(entry) => {
                let path = entry.path();
                if path.is_file() {
                    if let Err(e) = remove_empty_lines(path) {
                        eprintln!("Error processing {:?}: {}", path, e);
                    }
                }
            }
            Err(err) => eprintln!("Error walking directory: {}", err),
        }
    }
    Ok(())
}

fn remove_empty_lines(path: &Path) -> Result<()> {
    let data = fs::read(path).with_context(|| format!("Failed to read file: {:?}", path))?;
    
    if content_inspector::inspect(&data).is_binary() {
        return Ok(());
    }

    let reader = BufReader::new(&data[..]);
    let mut new_lines = Vec::new();

    for line_result in reader.lines() {
        let line = line_result?;
        if !line.trim().is_empty() {
            new_lines.push(line);
        }
    }

    let mut output = Vec::new();
    for line in new_lines {
        writeln!(output, "{}", line)?;
    }

    if output != data {
        fs::write(path, output).with_context(|| format!("Failed to write file: {:?}", path))?;
    }

    Ok(())
}

fn run_tests() -> Result<()> {
    println!("Running tests...");
    
    use tempfile::tempdir;
    let dir = tempdir()?;
    let root = dir.path();

    // 1. Create a file with empty lines
    let file1_path = root.join("test.txt");
    fs::write(&file1_path, "line1\n\nline2\n   \nline3\n")?;

    // 2. Create a .gitignore and a file that should be ignored
    let gitignore_path = root.join(".gitignore");
    fs::write(&gitignore_path, "ignored.txt\n")?;
    let ignored_path = root.join("ignored.txt");
    fs::write(&ignored_path, "should be ignored\n\n")?;

    // 3. Create a binary file (dummy)
    let binary_path = root.join("binary.bin");
    fs::write(&binary_path, [0, 15, 255, 0, 1, 2, 3])?;

    // Run the processor
    process_repo(root)?;

    // Verify file1: empty lines removed
    let content1 = fs::read_to_string(&file1_path)?;
    assert_eq!(content1, "line1\nline2\nline3\n");
    println!("test_remove_empty_lines ... ok");

    // Verify ignored file: should NOT be touched
    let content_ignored = fs::read_to_string(&ignored_path)?;
    assert_eq!(content_ignored, "should be ignored\n\n");
    println!("test_respect_gitignore ... ok");

    // Verify binary file: should NOT be touched
    let content_binary = fs::read(&binary_path)?;
    assert_eq!(content_binary, vec![0, 15, 255, 0, 1, 2, 3]);
    println!("test_skip_binary ... ok");

    println!("All tests passed!");
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_all() -> Result<()> {
        run_tests()
    }
}
