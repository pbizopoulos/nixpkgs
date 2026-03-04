import kotlin.system.exitProcess
fun runTests() {
    if (1 + 1 == 2) {
        println("test math ... ok")
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
        println("Hello Kotlin!")
    }
}
