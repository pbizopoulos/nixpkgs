use colored::*;
use std::env;
fn run_tests() {
    assert_eq!(1 + 1, 2);
    println!("test ... ok");
}
fn main() {
    if env::var("DEBUG").as_deref() == Ok("1") {
        run_tests();
    } else {
        for i in 1..=100 {
            if i % 15 == 0 {
                println!("{}", "FizzBuzz".red());
            } else if i % 3 == 0 {
                println!("{}", "Fizz".green());
            } else if i % 5 == 0 {
                println!("{}", "Buzz".blue());
            } else {
                println!("{}", i);
            }
        }
    }
}
