def runTests() {
    if (1 + 1 == 2) {
        println "test ... ok"
    } else {
        println "test math failed"
        System.exit(1)
    }
}
def debug = System.getenv("DEBUG")
if (debug == "1") {
    runTests()
} else {
    println "Hello World"
}
