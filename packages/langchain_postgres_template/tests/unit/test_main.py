# ruff: noqa: D100, D103, INP001, S101
from app.main import get_hello_world


def test_hello_world() -> None:
    assert get_hello_world() == "Hello World!"
