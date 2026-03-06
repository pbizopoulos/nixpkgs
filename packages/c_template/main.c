#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define RED "\033[0;31m"
#define GREEN "\033[0;32m"
#define BLUE "\033[0;34m"
#define RESET "\033[0m"
void run_tests(void);
void run_tests(void) {
  assert(1 + 1 == 2);
  printf("test ... ok\n");
}
int main(void) {
  const char *debug = getenv("DEBUG");
  if (debug && strcmp(debug, "1") == 0) {
    run_tests();
  } else {
    int i;
    for (i = 1; i <= 100; i++) {
      if (i % 15 == 0) {
        printf(RED "FizzBuzz\n" RESET);
      } else if (i % 3 == 0) {
        printf(GREEN "Fizz\n" RESET);
      } else if (i % 5 == 0) {
        printf(BLUE "Buzz\n" RESET);
      } else {
        printf("%d\n", i);
      }
    }
  }
  return 0;
}
