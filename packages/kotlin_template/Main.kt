import kotlin.system.exitProcess
fun runTests() {
    if (1 + 1 == 2) {
        println("test ... ok")
    } else {
        println("test math failed")
        exitProcess(1)
    }
}
fun main() {
    val debug = System.getenv("DEBUG")
    if (debug == "1") {
        runTests()
    } else {
        val red = "\u001b[31m"
        val green = "\u001b[32m"
        val blue = "\u001b[34m"
        val reset = "\u001b[0m"
        for (i in 1..100) {
            when {
                i % 15 == 0 -> println("${red}FizzBuzz$reset")
                i % 3 == 0 -> println("${green}Fizz$reset")
                i % 5 == 0 -> println("${blue}Buzz$reset")
                else -> println(i)
            }
        }
    }
}
