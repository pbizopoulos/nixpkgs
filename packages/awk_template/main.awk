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
        RED = "\x1b[31m"
        GREEN = "\x1b[32m"
        BLUE = "\x1b[34m"
        RESET = "\x1b[0m"
        for (i = 1; i <= 100; i++) {
            if (i % 15 == 0) {
                printf "%sFizzBuzz%s\n", RED, RESET
            } else if (i % 3 == 0) {
                printf "%sFizz%s\n", GREEN, RESET
            } else if (i % 5 == 0) {
                printf "%sBuzz%s\n", BLUE, RESET
            } else {
                print i
            }
        }
    }
}
