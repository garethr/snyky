from flask import Flask
import logging

app = Flask(__name__)

handler = logging.StreamHandler()
handler.setLevel(logging.INFO)
handler.setFormatter(formatter)
app.logger.addHandler(handler)
app.logger.setLevel(logging.INFO)


@app.route("/")
def hello():
    return "Hello World"


if __name__ == "__main__":
    app.run(host="0.0.0.0")
