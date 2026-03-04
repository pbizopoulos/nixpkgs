import os
proc runTests() =
  if 1 + 1 != 2:
    stderr.writeLine("test math failed")
    quit(1)
  echo "test math ... ok"
if getEnv("DEBUG") == "1":
  runTests()
else:
  echo "Hello Nim!"
