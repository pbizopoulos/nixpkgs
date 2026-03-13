#include <cassert>
#include <iostream>
#include <nlohmann/json.hpp>
#include <string>
using json = nlohmann::json;
static void run_tests() {
  assert(1 + 1 == 2);
  std::cout << "test ... ok" << std::endl;
}
int main() {
  const char *debug = std::getenv("DEBUG");
  if (debug && std::string(debug) == "1") {
    run_tests();
  } else {
    std::cout << "Hello World" << std::endl;
  }
  return 0;
}
