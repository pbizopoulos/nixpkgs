sub run-tests() {
    if 1 + 1 == 2 {
        say "test ... ok";
    } else {
        say "test ... failed";
        exit 1;
    }
}
if %*ENV<DEBUG> // "" eq "1" {
    run-tests();
} else {
    say "Hello World"
}
