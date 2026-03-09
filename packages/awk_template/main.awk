function run_tests() {
    if (1 + 1 == 2) {
        print "test ... ok"
    } else {
        print "test math failed"
        exit 1
    }
}
BEGIN {
    if (ENVIRON["DEBUG"] == "1") {
        run_tests()
    } else {
        print "Hello World"
    }
}
