#!/usr/bin/env python3
"""Python Hello World."""

import os


def run_tests() -> None:
    """Run tests."""
    assert 1 + 1 == 2  # noqa: PLR2004, S101
    print("test ... ok")


def main() -> None:
    """Run main."""
    if os.getenv("DEBUG") == "1":
        run_tests()
    else:
        print("Hello World")


if __name__ == "__main__":
    main()
