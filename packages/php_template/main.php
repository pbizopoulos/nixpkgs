<?php
function run_tests()
{
    if (1 + 1 !== 2) {
        echo "test math failed
";
        exit(1);
    }
    echo "test math ... ok
";
}
if (getenv("DEBUG") === "1") {
    run_tests();
} else {
    echo "Hello PHP!
";
}
