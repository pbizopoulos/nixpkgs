use pprof::ProfilerGuard;
#[allow(dead_code)]
fn run_tests() {
    let x = 1 + 1;
    assert_eq!(x, 2);
    println!("test ... ok");
}
fn main() {
    if std::env::var("DEBUG").as_deref() == Ok("1") {
        let guard = ProfilerGuard::new(100).expect("Failed to start profiler");
        run_tests();
        if let Ok(report) = guard.report().build() {
            println!("{report:?}");
        }
        return;
    }
    println!("Hello World");
}
#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn test_all() {
        run_tests();
    }
}
