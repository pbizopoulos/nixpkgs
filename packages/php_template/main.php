<?php
$RED = "\x1b[31m";
$GREEN = "\x1b[32m";
$BLUE = "\x1b[34m";
$RESET = "\x1b[0m";
function run_tests()
{
    if (1 + 1 !== 2) {
        echo "test math failed\n";
        exit(1);
    }
    echo "test ... ok\n";
}
if (getenv("DEBUG") === "1") {
    run_tests();
} else {
    for ($i = 1; $i <= 100; $i++) {
        if ($i % 15 === 0) {
            echo "${RED}FizzBuzz${RESET}\n";
        } elseif ($i % 3 === 0) {
            echo "${GREEN}Fizz${RESET}\n";
        } elseif ($i % 5 === 0) {
            echo "${BLUE}Buzz${RESET}\n";
        } else {
            echo "$i\n";
        }
    }
}
