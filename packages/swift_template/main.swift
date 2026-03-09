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
  print("Hello World")
}
