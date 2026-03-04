package main
import "core:fmt"
import "core:os"
run_tests :: proc() {
	if 1 + 1 != 2 {
		fmt.println("test math failed")
		os.exit(1)
	}
	fmt.println("test math ... ok")
}
main :: proc() {
	debug, _ := os.lookup_env("DEBUG")
	if debug == "1" {
		run_tests()
	} else {
		fmt.println("Hello Odin!")
	}
}
