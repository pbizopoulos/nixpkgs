from django.test import Client


def test_hello_world() -> None:
    client = Client()
    response = client.get("/")
    assert response.status_code == 200
    assert response.content == b"Hello World!"
