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
    Write-Output "Hello World"
}
