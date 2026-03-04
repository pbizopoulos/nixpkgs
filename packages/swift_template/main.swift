func runTests() {
    if 1 + 1 == 2 {
        print("test math ... ok")
    } else {
        print("test math failed")
    }
}
let args = CommandLine.arguments
if args.contains("DEBUG=1") {
    runTests()
} else {
    print("Hello Swift!")
}
