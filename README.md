# Snyky

[![CircleCI](https://circleci.com/gh/garethr/snyky.svg?style=svg)](https://circleci.com/gh/garethr/snyky)

![Gatekeeper](https://github.com/garethr/snyky/workflows/Gatekeeper/badge.svg)
![Policy](https://github.com/garethr/snyky/workflows/Policy/badge.svg)
![Snyk](https://github.com/garethr/snyky/workflows/Snyk/badge.svg)

The following application is used for demonstration purposes only. It contains a large number of overlapping
integrations described below.


## Policy

Snyky makes extensive use of [Opne Policy Agent](https://openpolicyagent.org) to validate that various policies are met. This includes:

* Checking properties of the `pytest.ini` file
* Checking the build instructions in the `Dockerfile`
* Checking dependencies in `Pipfile`
* Checking the Kubernetes configuration in the Helm Chart

These policies can be applied in a variety of different ways. Note this is for demonstration purposes only, it's likely that
you would only use one or two of these in a real application.

1. Using Conftest
2. Using GitHub Actions
3. In CircleCI
4. In a Tekton Pipeline
5. Using Docker
6. As part of a Python unit test suite
7. Using Gatekeeper


### 1. Using Conftest 

[Conftest](https://github.com/instrumenta/conftest) provides a developer focused user interface for Open Policy Agent. Let's first run the tests for our policies to make sure everything is in order:

```console
$ conftest verify
PASS - policy/policy/pytest_test.rego - data.pytest.test_require_black
PASS - policy/policy/pytest_test.rego - data.pytest.test_require_isort
PASS - policy/policy/pytest_test.rego - data.pytest.test_require_isort_and_black
PASS - policy/policy/pytest_test.rego - data.pytest.test_recommend_coverage
PASS - policy/policy/pytest_test.rego - data.pytest.test_recommend_type_checker
PASS - policy/policy/pytest_test.rego - data.pytest.test_valid_with_required_options
PASS - policy/policy/pytest_test.rego - data.pytest.test_no_warnings_with_recommended_option
```

Then let's demontrate running some of our tests to verify our Pytest configuration meets with our defined policy.

```console
$ conftest test --namespace pytest pytest.ini
WARN - pytest.ini - Consider enforcing type checking when running tests
WARN - pytest.ini - Consider enabling coverage reporting for test
```

You can see the policy in [policy/pytest.rego](policy/pytest.rego).



### 2. Using GitHub Actions

### 3. In CircleCI

### 4. In a Tekton Pipeline

### 5. Using Docker

### 6. As part of a Python unit test suite

### 7. Using Gatekeeper


## Vulnerabilities

Snyky also demonstrates different ways of integrating vulnerability scanning with a Python project using [Snyk](https://snyk.io).

1. Using Snyk locally
2. Using GitHub Actions
3. In CircleCI
4. In a Tekton Pipeline
5. Using Docker


### 1. Using Snyk locally

### 2. Using GitHub Actions

### 3. In CircleCI

### 4. In a Tekton Pipeline

### 5. Using Docker


## Installation

The full set of examples requires several tools to be installed:

* Conftest
* Docker
* Helm
* Conftest plugin for Helm
* Kubernetes
* Pipenv
* Python 3.7+
* Snyk
* Tilt


