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
  cat("Hello World\n")
}
