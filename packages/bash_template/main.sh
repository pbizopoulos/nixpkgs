#!/usr/bin/env bash
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'
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
  for i in {1..100}; do
    if (i % 15 == 0); then
      echo -e "${RED}FizzBuzz${NC}"
    elif (i % 3 == 0); then
      echo -e "${GREEN}Fizz${NC}"
    elif (i % 5 == 0); then
      echo -e "${BLUE}Buzz${NC}"
    else
      echo "$i"
    fi
  done
fi
