package main
import (
	"fmt"
	"os"
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
		fmt.Println("Hello World")
	}
}
