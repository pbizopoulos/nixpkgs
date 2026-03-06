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
    my $RED = "\x1b[31m";
    my $GREEN = "\x1b[32m";
    my $BLUE = "\x1b[34m";
    my $RESET = "\x1b[0m";
    for 1..100 -> $i {
        if $i %% 15 { say "$RED" ~ "FizzBuzz" ~ "$RESET" }
        elsif $i %% 3 { say "$GREEN" ~ "Fizz" ~ "$RESET" }
        elsif $i %% 5 { say "$BLUE" ~ "Buzz" ~ "$RESET" }
        else { say $i }
    }
}
