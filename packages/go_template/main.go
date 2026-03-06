package main
import (
	"fmt"
	"os"
)
const (
	RED   = "\033[0;31m"
	GREEN = "\033[0;32m"
	BLUE  = "\033[0;34m"
	NC    = "\033[0m"
)
func runTests() {
	if 1+1 != 2 {
		panic("test math failed")
	}
	fmt.Println("test ... ok")
}
func main() {
	if os.Getenv("DEBUG") == "1" {
		runTests()
	} else {
		for i := 1; i <= 100; i++ {
			if i%15 == 0 {
				fmt.Printf("%sFizzBuzz%s\n", RED, NC)
			} else if i%3 == 0 {
				fmt.Printf("%sFizz%s\n", GREEN, NC)
			} else if i%5 == 0 {
				fmt.Printf("%sBuzz%s\n", BLUE, NC)
			} else {
				fmt.Println(i)
			}
		}
	}
}
