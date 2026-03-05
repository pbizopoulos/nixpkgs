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
    print('Hello Dart!');
  }
}
