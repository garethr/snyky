import pytest
from policykit import Conftest


class TestPolicy(object):
    @pytest.fixture
    def conftest(self):
        return Conftest()

    def test_policy(self, conftest):
        run = conftest.verify()
        assert run.success

    def test_pytest_config(self, conftest):
        run = conftest.test("pytest.ini", namespace="pytest")
        assert run.success

    def test_pipfile(self, conftest):
        run = conftest.test("Pipfile", namespace="pipfile", input="toml")
        assert run.success

    def test_dockerfile(self, conftest):
        run = conftest.test("Dockerfile", namespace="docker")
        assert run.success

    def test_kubernetes_manifest_for_warnings(self, conftest):
        run = conftest.test("snyky.yaml")
        result = run.results[0]
        assert not result.Warnings
