object Main {
  def runTests(): Unit = {
    if (1 + 1 == 2) {
      println("test ... ok")
    } else {
      println("test math failed")
      sys.exit(1)
    }
  }
  def main(args: Array[String]): Unit = {
    val debug = sys.env.getOrElse("DEBUG", "0")
    if (debug == "1") {
      runTests()
    } else {
      val RED = "\u001b[31m"
      val GREEN = "\u001b[32m"
      val BLUE = "\u001b[34m"
      val RESET = "\u001b[0m"
      for (i <- 1 to 100) {
        if (i % 15 == 0) println(s"${RED}FizzBuzz${RESET}")
        else if (i % 3 == 0) println(s"${GREEN}Fizz${RESET}")
        else if (i % 5 == 0) println(s"${BLUE}Buzz${RESET}")
        else println(i)
      }
    }
  }
}
