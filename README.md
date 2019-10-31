# Snyky

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

1. [Using Conftest](#1-using-conftest)
2. [Using GitHub Actions](#2-using-github-actions)
3. [In CircleCI](#3-in-circleci)
4. [In a Tekton Pipeline](#4-in-a-tekton-pipeline)
5. [Using Docker](#5-using-docker)
6. [As part of a Python unit test suite](#6-as-part-of-a-python-unit-test-suite)
7. [Using Gatekeeper](#7-using-gatekeeper)


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

Conftest has a [GitHub Action](https://github.com/instrumenta/conftest-action) which makes integrating policy testing into GitHub easier. This includes Actions for using Conftest and a separate action for using the Conftest Helm plugin. You can see these running in this repository.

![Policy](https://github.com/garethr/snyky/workflows/Policy/badge.svg)

For the workflow definition see [.github/workflows/policy.yml](.github/workflow/policy.yml).

### 3. In CircleCI

Conftest has a [CircleCI Orb](https://circleci.com/orbs/registry/orb/kenfdev/conftest-orb) which makes setting up Conftest in a CircleCI build straighforward. The Orb provides a number of different commands and you can see some of them in use in this repository.

[![CircleCI](https://circleci.com/gh/garethr/snyky.svg?style=svg)](https://circleci.com/gh/garethr/snyky)

For the build configuration see [.circleci/config.yml](.circleci/config.yml).

### 4. In a Tekton Pipeline

### 5. Using Docker

There are two approaches to using Conftest with Docker. The simplest is just mounting the project and running the Conftest Docker image like so.

```console
$ docker run --rm -v (pwd):/project instrumenta/conftest test snyky.yaml
FAIL - snyky.yaml - snyky in the Deployment garethr/snyky has an image, snyky, using the latest tag
FAIL - snyky.yaml - snyky in the Deployment snyky does not have a memory limit set
FAIL - snyky.yaml - snyky in the Deployment snyky does not have a CPU limit set
FAIL - snyky.yaml - snyky in the Deployment snyky doesn't drop all capabilities
FAIL - snyky.yaml - snyky in the Deployment snyky is not using a read only root filesystem
FAIL - snyky.yaml - snyky in the Deployment snyky is running as roo
```

A more advanced pattern is to add Conftest to a Docker image like so:

```dockerfile
COPY --from=instrumenta/conftest /conftest /usr/local/bin/conftest
```

And then use it as part of a Docker build.

```console
$ docker build --target Policy .
[+] Building 3.6s (18/18) FINISHED
 => [internal] load build definition from Dockerfile                                                                     0.0s
 => => transferring dockerfile: 37B                                                                                      0.0s
 => [internal] load .dockerignore                                                                                        0.0s
 => => transferring context: 2B                                                                                          0.0s
 => [internal] load metadata for docker.io/library/python:3.7-alpine3.8                                                  0.0s
 => [internal] load build context                                                                                        0.1s
 => => transferring context: 36.87kB                                                                                     0.1s
 => FROM docker.io/instrumenta/conftest:latest                                                                           0.0s
 => [pipenv 1/2] FROM docker.io/library/python:3.7-alpine3.8                                                             0.0s
 => CACHED [pipenv 2/2] RUN pip3 install pipenv                                                                          0.0s
 => CACHED [parent 1/4] WORKDIR /app                                                                                     0.0s
 => CACHED [parent 2/4] COPY Pipfile /app/                                                                               0.0s
 => CACHED [parent 3/4] COPY Pipfile.lock /app/                                                                          0.0s
 => CACHED [parent 4/4] RUN apk add --no-cache --update git=2.18.1-r0                                                    0.0s
 => CACHED [dev-base 1/3] COPY --from=instrumenta/conftest /conftest /usr/local/bin/conftest                             0.0s
 => CACHED [dev-base 2/3] RUN pipenv install --dev                                                                       0.0s
 => CACHED [dev-base 3/3] COPY . /app                                                                                    0.0s
 => [policy 1/4] RUN conftest test --namespace pytest pytest.ini                                                         0.8s
 => [policy 2/4] RUN conftest test --namespace pipfile --input toml Pipfile                                              0.8s
 => [policy 3/4] RUN conftest test --namespace docker Dockerfile                                                         0.9s
 => ERROR [policy 4/4] RUN conftest test snyky.yaml                                                                      0.9s
------
 > [policy 4/4] RUN conftest test snyky.yaml:
#18 0.631 FAIL - snyky.yaml - snyky in the Deployment garethr/snyky has an image, snyky, using the latest tag
#18 0.631 FAIL - snyky.yaml - snyky in the Deployment snyky does not have a memory limit set
#18 0.631 FAIL - snyky.yaml - snyky in the Deployment snyky does not have a CPU limit set
#18 0.631 FAIL - snyky.yaml - snyky in the Deployment snyky doesn't drop all capabilities
#18 0.631 FAIL - snyky.yaml - snyky in the Deployment snyky is not using a read only root filesystem
#18 0.631 FAIL - snyky.yaml - snyky in the Deployment snyky is running as root
------
failed to solve with frontend dockerfile.v0: failed to build LLB: executor failed running [/bin/sh -c conftest test snyky.yaml]: runc did not terminate sucessfully
```

### 6. As part of a Python unit test suite

Using [Policykit](https://github.com/garethr/policykit/) it's possible to integrate Conftest output with Python, and to
use it with a unit testing framework, in this case pytest.

```console
$ pipenv run pytest src/test_policy.py
========================================= test session starts ==========================================
platform darwin -- Python 3.7.4, pytest-5.2.2, py-1.8.0, pluggy-0.13.0
cachedir: .pytest_cache
rootdir: /Users/garethr/Documents/snyky, inifile: pytest.ini
plugins: isort-0.3.1, black-0.3.7, flask-0.15.0
collected 7 items

src/test_policy.py::BLACK SKIPPED                                                                 [ 14%]
src/test_policy.py::ISORT SKIPPED                                                                 [ 28%]
src/test_policy.py::TestPolicy::test_policy PASSED                                                [ 42%]
src/test_policy.py::TestPolicy::test_pytest_config PASSED                                         [ 57%]
src/test_policy.py::TestPolicy::test_pipfile PASSED                                               [ 71%]
src/test_policy.py::TestPolicy::test_dockerfile PASSED                                            [ 85%]
src/test_policy.py::TestPolicy::test_kubernetes_manifest_for_warnings PASSED                      [100%]

===================================== 5 passed, 2 skipped in 0.47s =====================================
```

You can see the unit tests in [src/test_policy.py](src/test_policy.py).


### 7. Using Gatekeeper

![Gatekeeper](https://github.com/garethr/snyky/workflows/Gatekeeper/badge.svg)


## Vulnerabilities

Snyky also demonstrates different ways of integrating vulnerability scanning with a Python project using [Snyk](https://snyk.io).

1. Using Snyk locally
2. Using GitHub Actions
3. In CircleCI
4. In a Tekton Pipeline
5. Using Docker


### 1. Using Snyk locally

### 2. Using GitHub Actions

![Snyk](https://github.com/garethr/snyky/workflows/Snyk/badge.svg)

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
