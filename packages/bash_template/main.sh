#!/usr/bin/env bash
run_tests() {
  if [ $((1 + 1)) -ne 2 ]; then
    echo "test math failed"
    exit 1
  fi
  echo "test ... ok"
}
if [ "$DEBUG" == "1" ]; then
  run_tests
else
  echo "Hello World"
fi
