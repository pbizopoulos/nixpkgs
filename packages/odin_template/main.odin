package main
import "core:fmt"
import "core:os"
run_tests :: proc() {
	if 1 + 1 != 2 {
		fmt.println("test math failed")
		os.exit(1)
	}
	fmt.println("test ... ok")
}
main :: proc() {
	debug, _ := os.lookup_env("DEBUG")
	if debug == "1" {
		run_tests()
	} else {
		RED :: "\x1b[31m"
		GREEN :: "\x1b[32m"
		BLUE :: "\x1b[34m"
		RESET :: "\x1b[0m"
		for i in 1..=100 {
			if i % 15 == 0 { fmt.printf("%sFizzBuzz%s\n", RED, RESET) }
			else if i % 3 == 0 { fmt.printf("%sFizz%s\n", GREEN, RESET) }
			else if i % 5 == 0 { fmt.printf("%sBuzz%s\n", BLUE, RESET) }
			else { fmt.println(i) }
		}
	}
}
