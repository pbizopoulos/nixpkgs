#!/usr/bin/env python3
"""Python FizzBuzz with color."""

import os
from termcolor import colored


def run_tests() -> None:
    """Run tests."""
    assert 1 + 1 == 2  # noqa: PLR2004, S101
    print("test ... ok")


def main() -> None:
    """Run main."""
    if os.getenv("DEBUG") == "1":
        run_tests()
    else:
        for i in range(1, 101):
            if i % 15 == 0:
                print(colored("FizzBuzz", "red"))
            elif i % 3 == 0:
                print(colored("Fizz", "green"))
            elif i % 5 == 0:
                print(colored("Buzz", "blue"))
            else:
                print(i)


if __name__ == "__main__":
    main()
