# ruff: noqa: D100, D103, INP001, PLR2004, S101
from app.main import app
from fastapi.testclient import TestClient

client = TestClient(app)


def test_read_main() -> None:
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "Hello World!"}
