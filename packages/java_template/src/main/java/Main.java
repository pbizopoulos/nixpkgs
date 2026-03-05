import java.util.HashMap;
import java.util.Map;
public class Main {
  public static void main(String[] args) {
    String debug = System.getenv("DEBUG");
    if ("1".equals(debug)) {
      runTests();
    } else {
      System.out.println("Hello Java!");
      Map<String, String> data = new HashMap<>();
      data.put("message", "Hello, world!");
      data.put("language", "Java");
      System.out.println(data);
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
