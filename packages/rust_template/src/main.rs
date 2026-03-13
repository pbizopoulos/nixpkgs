use std::env;
fn run_tests() {
    let x = 1 + 1;
    assert_eq!(x, 2);
    println!("test ... ok");
}
fn main() {
    if env::var("DEBUG").as_deref() == Ok("1") {
        run_tests();
    } else {
        println!("Hello World");
    }
}
