#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
void run_tests(void);
void run_tests(void) {
  assert(1 + 1 == 2);
  printf("test math ... ok\n");
}
int main(void) {
  const char *debug = getenv("DEBUG");
  if (debug && strcmp(debug, "1") == 0) {
    run_tests();
  } else {
    printf("Hello, World!\n");
  }
  return 0;
}
