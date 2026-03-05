#!/usr/bin/env python3
"""Python."""

import json
import os


def run_tests() -> None:
    """Run tests."""
    assert 1 + 1 == 2  # noqa: PLR2004, S101


def main() -> None:
    """Run main."""
    if os.getenv("DEBUG") == "1":
        run_tests()
    else:
        print("Hello world!")  # noqa: T201
        data = {"message": "Hello, world!", "language": "Python"}
        print(json.dumps(data))


if __name__ == "__main__":
    main()
