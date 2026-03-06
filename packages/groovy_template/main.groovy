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
    def RED = "\u001b[31m"
    def GREEN = "\u001b[32m"
    def BLUE = "\u001b[34m"
    def RESET = "\u001b[0m"
    (1..100).each { i ->
        if (i % 15 == 0) println "${RED}FizzBuzz${RESET}"
        else if (i % 3 == 0) println "${GREEN}Fizz${RESET}"
        else if (i % 5 == 0) println "${BLUE}Buzz${RESET}"
        else println i
    }
}
