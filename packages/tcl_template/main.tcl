if {[info exists env(DEBUG)] && $env(DEBUG) == "1"} {
    puts "test ... ok"
} else {
    puts "Hello Tcl!"
}
