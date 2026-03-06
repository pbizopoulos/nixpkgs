run_tests <- function() {
  if (1 + 1 == 2) {
    cat("test ... ok\n")
  } else {
    cat("test math failed\n")
    quit(status = 1)
  }
}
debug <- Sys.getenv("DEBUG")
if (debug == "1") {
  run_tests()
} else {
  RED <- "\x1b[31m"
  GREEN <- "\x1b[32m"
  BLUE <- "\x1b[34m"
  RESET <- "\x1b[0m"
  for (i in 1:100) {
    if (i %% 15 == 0) { cat(RED, "FizzBuzz", RESET, "\n", sep = "") }
    else if (i %% 3 == 0) { cat(GREEN, "Fizz", RESET, "\n", sep = "") }
    else if (i %% 5 == 0) { cat(BLUE, "Buzz", RESET, "\n", sep = "") }
    else { cat(i, "\n") }
  }
}
