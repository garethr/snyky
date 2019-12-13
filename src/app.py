import logging

from flask import Flask

app = Flask(__name__)

handler = logging.StreamHandler()
handler.setLevel(logging.INFO)
app.logger.addHandler(handler)
app.logger.setLevel(logging.INFO)


@app.route("/")
def hello():
    return "Hello World"


if __name__ == "__main__":
    app.run(host="0.0.0.0")
