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
    puts "Hello World"
}
