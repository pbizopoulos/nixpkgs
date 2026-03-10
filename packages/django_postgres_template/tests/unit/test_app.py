# ruff: noqa: D100, D103, INP001, PLR2004, S101
from django.test import Client


def test_hello_world() -> None:
    client = Client()
    response = client.get("/")
    assert response.status_code == 200
    assert response.content == b"Hello World!"
