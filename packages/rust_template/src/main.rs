fn main() {
    if std::env::var("DEBUG").as_deref() == Ok("1") {
        run_tests();
    } else {
        println!("Hello, world!");
        println!("{{\"message\": \"Hello, world!\", \"language\": \"Rust\"}}");
    }
}
fn run_tests() {
    test_hello_world();
    test_math();
}
fn test_hello_world() {
    assert_eq!(2 + 2, 4);
    println!("test hello_world ... ok");
}
fn test_math() {
    assert!(2 * 3 == 6);
    println!("test ... ok");
}
#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn test_hello_world_test() {
        test_hello_world();
    }
    #[test]
    fn test_math_test() {
        test_math();
    }
}
