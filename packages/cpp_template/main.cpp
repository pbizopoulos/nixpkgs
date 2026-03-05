#include <cassert>
#include <iostream>
#include <string>
void run_tests() {
  assert(1 + 1 == 2);
  std::cout << "test ... ok" << std::endl;
}
int main() {
  const char *debug = std::getenv("DEBUG");
  if (debug && std::string(debug) == "1") {
    run_tests();
  } else {
    std::cout << "Hello C++!" << std::endl;
  }
  return 0;
}
