import logging
from flask import Flask


def app():
    application = Flask(__name__)

    @application.route("/")
    def hello():
        return "Hello World"

    @application.route("/error")
    def error():
        assert application.debug == False

    return application


if __name__ == "__main__":
    app().run(host="0.0.0.0")
