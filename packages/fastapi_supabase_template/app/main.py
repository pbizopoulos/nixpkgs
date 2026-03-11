# ruff: noqa: D100, D103, INP001
from fastapi import FastAPI

app = FastAPI()


@app.get("/")  # type: ignore[untyped-decorator]
async def root() -> dict[str, str]:
    return {"message": "Hello World!"}
