function Run-Tests {
    if (1 + 1 -eq 2) {
        Write-Output "test ... ok"
    } else {
        Write-Output "test math failed"
        exit 1
    }
}
$debug = $env:DEBUG
if ($debug -eq "1") {
    Run-Tests
} else {
    $RED = "$([char]27)[31m"
    $GREEN = "$([char]27)[32m"
    $BLUE = "$([char]27)[34m"
    $RESET = "$([char]27)[0m"
    for ($i = 1; $i -le 100; $i++) {
        if ($i % 15 -eq 0) { Write-Output "${RED}FizzBuzz${RESET}" }
        elseif ($i % 3 -eq 0) { Write-Output "${GREEN}Fizz${RESET}" }
        elseif ($i % 5 -eq 0) { Write-Output "${BLUE}Buzz${RESET}" }
        else { Write-Output $i }
    }
}
