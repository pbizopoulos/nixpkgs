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
      println("Hello Scala!")
      val data = Map("message" -> "Hello, world!", "language" -> "Scala")
      println(data)
    }
  }
}
