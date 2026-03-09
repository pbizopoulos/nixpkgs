<?php
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
    echo "Hello World\n";
}
