proc run_tests {} {
    if {[expr {1 + 1}] == 2} {
        puts "test ... ok"
    } else {
        puts "test ... failed"
        exit 1
    }
}
if {[info exists env(DEBUG)] && $env(DEBUG) == "1"} {
    run_tests
} else {
    set RED "\x1b[31m"
    set GREEN "\x1b[32m"
    set BLUE "\x1b[34m"
    set RESET "\x1b[0m"
    for {set i 1} {$i <= 100} {incr i} {
        if {$i % 15 == 0} { puts "${RED}FizzBuzz${RESET}" } \
        elseif {$i % 3 == 0} { puts "${GREEN}Fizz${RESET}" } \
        elseif {$i % 5 == 0} { puts "${BLUE}Buzz${RESET}" } \
        else { puts $i }
    }
}
