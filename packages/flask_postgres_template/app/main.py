import os
from flask import Flask

app = Flask(__name__)


@app.route("/")  # type: ignore
def hello_world() -> str:
    return "<p>Hello, Flask with Postgres!</p>"


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
