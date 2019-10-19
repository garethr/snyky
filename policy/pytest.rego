package pytest

deny[msg] {
    not contains(input.pytest.addopts, "--black")
    msg := "Must be using black for formatting code"
}

deny[msg] {
    not contains(input.pytest.addopts, "--isort")
    msg := "Must be sorting imports using isort"
}

warn[msg] {
    not contains(input.pytest.addopts, "--mypy")
    msg := "Consider enforcing type checking when running tests"
}

warn[msg] {
    not contains(input.pytest.addopts, "--cov")
    msg := "Consider enabling coverage reporting for tests"
}

