import 'dart:io';
void runTests() {
  if (1 + 1 != 2) {
    stderr.writeln('test math failed');
    exit(1);
  }
  print('test ... ok');
}
void main() {
  if (Platform.environment['DEBUG'] == '1') {
    runTests();
  } else {
    const RED = "\x1b[31m";
    const GREEN = "\x1b[32m";
    const BLUE = "\x1b[34m";
    const RESET = "\x1b[0m";
    for (int i = 1; i <= 100; i++) {
      if (i % 15 == 0)
        print('${RED}FizzBuzz${RESET}');
      else if (i % 3 == 0)
        print('${GREEN}Fizz${RESET}');
      else if (i % 5 == 0)
        print('${BLUE}Buzz${RESET}');
      else
        print(i);
    }
  }
}
