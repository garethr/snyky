import pytest

from app import app as application


@pytest.fixture
def app():
    app = application
    app.debug = True
    return app
