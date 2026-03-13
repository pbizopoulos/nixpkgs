#include <stdio.h>
#include <stdlib.h>
#include <string.h>
void run_tests(void) {
    if (1 + 1 == 2) {
        printf("test ... ok\n");
    } else {
        printf("test math failed\n");
    }
}
int main(int argc, char *argv[]) {
    (void)argc;
    (void)argv;
    const char *debug = getenv("DEBUG");
    if (debug && strcmp(debug, "1") == 0) {
        run_tests();
    } else {
        printf("Hello World\n");
    }
    return 0;
}
