import Foundation

func runTests() {
  if 1 + 1 == 2 {
    print("test ... ok")
  } else {
    print("test math failed")
  }
}
let debug = ProcessInfo.processInfo.environment["DEBUG"]
if debug == "1" {
  runTests()
} else {
  let RED = "\u{001B}[31m"
  let GREEN = "\u{001B}[32m"
  let BLUE = "\u{001B}[34m"
  let RESET = "\u{001B}[0m"
  for i in 1...100 {
    if i % 15 == 0 {
      print("\(RED)FizzBuzz\(RESET)")
    } else if i % 3 == 0 {
      print("\(GREEN)Fizz\(RESET)")
    } else if i % 5 == 0 {
      print("\(BLUE)Buzz\(RESET)")
    } else {
      print(i)
    }
  }
}
