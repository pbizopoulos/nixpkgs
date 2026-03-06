import os
proc runTests() =
  if 1 + 1 != 2:
    stderr.writeLine("test math failed")
    quit(1)
  echo "test ... ok"
if getEnv("DEBUG") == "1":
  runTests()
else:
  const RED = "\x1b[31m"
  const GREEN = "\x1b[32m"
  const BLUE = "\x1b[34m"
  const RESET = "\x1b[0m"
  for i in 1..100:
    if i mod 15 == 0: echo RED, "FizzBuzz", RESET
    elif i mod 3 == 0: echo GREEN, "Fizz", RESET
    elif i mod 5 == 0: echo BLUE, "Buzz", RESET
    else: echo i
