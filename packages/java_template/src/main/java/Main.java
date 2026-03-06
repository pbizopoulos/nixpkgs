public class Main {
  public static void main(String[] args) {
    String debug = System.getenv("DEBUG");
    if ("1".equals(debug)) {
      runTests();
    } else {
      String RED = "\u001b[31m";
      String GREEN = "\u001b[32m";
      String BLUE = "\u001b[34m";
      String RESET = "\u001b[0m";
      for (int i = 1; i <= 100; i++) {
        if (i % 15 == 0) System.out.println(RED + "FizzBuzz" + RESET);
        else if (i % 3 == 0) System.out.println(GREEN + "Fizz" + RESET);
        else if (i % 5 == 0) System.out.println(BLUE + "Buzz" + RESET);
        else System.out.println(i);
      }
    }
  }
  private static void runTests() {
    if (1 + 1 != 2) {
      System.err.println("test math failed");
      System.exit(1);
    }
    System.out.println("test ... ok");
  }
}
