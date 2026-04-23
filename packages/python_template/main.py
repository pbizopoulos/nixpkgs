"""Python Hello World."""  # noqa: INP001

import os


def run_tests() -> None:
    """Run tests."""
    assert 1 + 1 == 2  # noqa: PLR2004, S101
    print("test ... ok")  # noqa: T201


def main() -> None:
    """Run main."""
    if os.getenv("DEBUG") == "1":
        run_tests()
    else:
        print("Hello World")  # noqa: T201


if __name__ == "__main__":
    main()
