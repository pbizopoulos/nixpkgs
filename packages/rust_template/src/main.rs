use std::env;
fn run_tests() {
    assert_eq!(1 + 1, 2);
    println!("test ... ok");
}
fn main() {
    if env::var("DEBUG").as_deref() == Ok("1") {
        run_tests();
    } else {
        println!("Hello World");
    }
}
