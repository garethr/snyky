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

The application is packaged as a Helm chart, and you can use the [Conftest Helm plugin](https://github.com/instrumenta/helm-conftest) to render the chart template and run the resulting manifests through the local policy:

```console
$ helm conftest snyky
FAIL - snyky in the Deployment garethr/snyky has an image, snyky, using the latest tag
FAIL - snyky in the Deployment snyky does not have a memory limit set
FAIL - snyky in the Deployment snyky does not have a CPU limit set
FAIL - snyky in the Deployment snyky doesn't drop all capabilities
FAIL - snyky in the Deployment snyky is not using a read only root filesystem
FAIL - snyky in the Deployment snyky allows priviledge escalation
FAIL - snyky in the Deployment snyky is running as root
Error: plugin "conftest" exited with erro
```

### 2. Using GitHub Actions

Conftest has a [GitHub Action](https://github.com/instrumenta/conftest-action) which makes integrating policy testing into GitHub easier. This includes Actions for using Conftest and a separate action for using the Conftest Helm plugin. You can see these running in this repository.

![Policy](https://github.com/garethr/snyky/workflows/Policy/badge.svg)

For the workflow definition see [.github/workflows/policy.yml](.github/workflow/policy.yml).

### 3. In CircleCI

Conftest has a [CircleCI Orb](https://circleci.com/orbs/registry/orb/kenfdev/conftest-orb) which makes setting up Conftest in a CircleCI build straighforward. The Orb provides a number of different commands and you can see some of them in use in this repository.

[![CircleCI](https://circleci.com/gh/garethr/snyky.svg?style=svg)](https://circleci.com/gh/garethr/snyky)

For the build configuration see [.circleci/config.yml](.circleci/config.yml).

### 4. In a Tekton Pipeline

[Tekton](https://tekton.dev) provides a Kubernetes-native pipeline. The following requires you to have a Kubernetes cluster
running but will install the latest version of Tekton, as well as a custom pipeline for this project.

```console
$ make tekton-init
namespace/tekton-pipelines unchanged
podsecuritypolicy.policy/tekton-pipelines configured
clusterrole.rbac.authorization.k8s.io/tekton-pipelines-admin unchanged
serviceaccount/tekton-pipelines-controller unchanged
...
$ make tekton-pipeline
pipeline.tekton.dev/snyky-pipeline created
pipelineresource.tekton.dev/snyky-git created
task.tekton.dev/conftest-verify create
```

We can use the [Tekton CLI](https://github.com/tektoncd/cli) to start a run of our pipeline:

```console
$ tkn pipeline start snyky-pipelin
? Choose the git resource to use for source-repo: snyky-git (https://github.com/garethr/snyky.git)
Pipelinerun started: snyky-pipeline-run-xrg96

In order to track the pipelinerun progress run:
tkn pipelinerun logs snyky-pipeline-run-xrg96 -f -n defaul
```

We can also use `tkn` to grab the logs.

```console
$ tkn pipelinerun logs snyky-pipeline-run-xrg96 -f -n default
...
[pytest-conftest : conftest] WARN - pytest.ini - Consider enforcing type checking when running tests
[pytest-conftest : conftest] WARN - pytest.ini - Consider enabling coverage reporting for tests

[conftest-verify : conftest-verify] PASS - policy/policy/pytest_test.rego - data.pytest.test_require_black
[conftest-verify : conftest-verify] PASS - policy/policy/pytest_test.rego - data.pytest.test_require_isort
[conftest-verify : conftest-verify] PASS - policy/policy/pytest_test.rego - data.pytest.test_require_isort_and_black
[conftest-verify : conftest-verify] PASS - policy/policy/pytest_test.rego - data.pytest.test_recommend_coverage
[conftest-verify : conftest-verify] PASS - policy/policy/pytest_test.rego - data.pytest.test_recommend_type_checker
[conftest-verify : conftest-verify] PASS - policy/policy/pytest_test.rego - data.pytest.test_valid_with_required_options
[conftest-verify : conftest-verify] PASS - policy/policy/pytest_test.rego - data.pytest.test_no_warnings_with_recommended_options
...
```

If you prefer a graphical tool then run the Tekton dashboard:

```console
make tekton-dashboard
```

For the full pipeline configuration see [tekton/pipeline.yaml](tekton/pipeline.yaml).

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

You can also use the Conftest Helm plugin via Docker as well:

```console
$ docker run --rm -it -v (pwd):/chart instrumenta/helm-conftest conftest snyky
FAIL - snyky in the Deployment garethr/snyky has an image, snyky, using the latest tag
FAIL - snyky in the Deployment snyky does not have a memory limit set
FAIL - snyky in the Deployment snyky does not have a CPU limit set
FAIL - snyky in the Deployment snyky doesn't drop all capabilities
FAIL - snyky in the Deployment snyky is not using a read only root filesystem
FAIL - snyky in the Deployment snyky allows priviledge escalation
FAIL - snyky in the Deployment snyky is running as root
Error: plugin "conftest" exited with erro
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

The repository is also setup to make using [Gatekeeper](https://github.com/open-policy-agent/gatekeeper) possible as well.

First we need to generate a Gatekeeper `ConstraintTemplate` from our rego policies. This is done using the GitHub Action from [Policykit](https://github.com/garethr/policykit/).

![Gatekeeper](https://github.com/garethr/snyky/workflows/Gatekeeper/badge.svg)

This generates [policy/SecurityControls.yaml](policy/SecurityControls.yaml).

(Note that currently this requires the [new `lib` functionality currently in HEAD](https://github.com/open-policy-agent/gatekeeper/pull/270).)

```console
kubectl apply -f policy/SecurityControls.yaml
```

With the `ConstraintTemplate` configured we can create a constraint:

```yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: SecurityControls
metadata:
  name: enforce-deployment-and-pod-security-controls
spec:
  match:
    kinds:
      - apiGroups: ["batch", "extensions", "apps", ""]
        kinds: ["Deployment", "Pod", "CronJob", "Job", "StatefulSet", "DaemonSet", "ConfigMap", "Service"]
```

As configured above this will use the admission controller to block requests that do not meet our policies.

```console
$ kubectl apply -f gatekeeper/deployment.yaml
Error from server ([denied by enforce-deployment-and-pod-security-controls] nginx in the Deployment nginx-deployment does not have a memory limit set
[denied by enforce-deployment-and-pod-security-controls] nginx in the Deployment nginx-deployment does not have a CPU limit set
[denied by enforce-deployment-and-pod-security-controls] nginx in the Deployment nginx-deployment doesn't drop all capabilities
[denied by enforce-deployment-and-pod-security-controls] nginx in the Deployment nginx-deployment is not using a read only root filesystem
[denied by enforce-deployment-and-pod-security-controls] nginx in the Deployment nginx-deployment is running as root): error when creating "deployment.yaml": admission webhook "validation.gatekeeper.sh" denied the request: [denied by enforce-deployment-and-pod-security-controls] nginx in the Deployment nginx-deployment does not have a memory limit set
[denied by enforce-deployment-and-pod-security-controls] nginx in the Deployment nginx-deployment does not have a CPU limit set
[denied by enforce-deployment-and-pod-security-controls] nginx in the Deployment nginx-deployment doesn't drop all capabilities
[denied by enforce-deployment-and-pod-security-controls] nginx in the Deployment nginx-deployment is not using a read only root filesystem
[denied by enforce-deployment-and-pod-security-controls] nginx in the Deployment nginx-deployment is running as roo
```

We can also set the policies up in `dryrun` mode and view any violations in the status field of the constraint.

```console
$ kubectl get SecurityControls audit-deployment-and-pod-security-controls -o yaml
...
  - enforcementAction: dryrun
    kind: Deployment
    message: nginx in the Deployment nginx-deployment doesn't drop all capabilities
    name: nginx-deployment
    namespace: audit
  - enforcementAction: dryrun
    kind: Deployment
    message: nginx in the Deployment nginx-deployment is not using a read only root
      filesystem
    name: nginx-deployment
    namespace: audit
  - enforcementAction: dryrun
    kind: Deployment
    message: nginx in the Deployment nginx-deployment allows priviledge escalation
    name: nginx-deployment
    namespace: audit
  - enforcementAction: dryrun
    kind: Deployment
    message: nginx in the Deployment nginx-deployment is running as root
    name: nginx-deployment
    namespace: audit
```

Gatekeeper is opinionated about input and output, if you are interested in writing policies compatible with Gatekeeper and other OPA tools like Conftest then note the `is_gatekeeper` and `gatekeeper_format` rules in [policy/lib/kubernetes.rego](policy/lib/kubernetes.rego).


## Vulnerabilities

Snyky also demonstrates different ways of integrating vulnerability scanning with a Python project using [Snyk](https://snyk.io).

1. [Using Snyk locally](#1-using-snyk-locally-1)
2. [Using GitHub Actions](#2-using-github-actions-1)
3. [In CircleCI](#3-in-circleci-1)
4. [In a Tekton Pipeline](#4-in-a-tekton-pipeline-1)
5. [Using Docker](#5-using-docker-1)


### 1. Using Snyk locally

Snyk can be installed locally, using NPM, or using [Homebrew](https://github.com/snyk/homebrew-tap) or [Scoop](https://github.com/snyk/scoop-snyk).

```console
$ snyk test

Tested 7 dependencies for known issues, found 2 issues, 2 vulnerable paths.


Issues with no direct upgrade or patch:
  ✗ Improper Input Validation [High Severity][https://snyk.io/vuln/SNYK-PYTHON-FLASK-42185] in flask@0.12
  This issue was fixed in versions: 0.12.3
  ✗ Denial of Service (DOS) [High Severity][https://snyk.io/vuln/SNYK-PYTHON-FLASK-451637] in flask@0.12
  This issue was fixed in versions: 1.0



Organization:      garethr
Package manager:   pip
Target file:       Pipfile
Open source:       no
Project path:      /Users/garethr/Documents/snyky
Licenses:          enable
```

### 2. Using GitHub Actions

Snyk has a [set of GitHub Actions](https://github.com/garethr/snyk-actions) which can be used to check for vulnerabilities in
appications and Docker images.

![Snyk](https://github.com/garethr/snyky/workflows/Snyk/badge.svg)

For the workflow definition see [.github/workflows/snyk.yml](.github/workflow/snyk.yml).

### 3. In CircleCI

Snyk has a [CircleCI Orb](https://circleci.com/orbs/registry/orb/snyk/snyk) which can be used to check for vulnerabilities
in your CI builds.

### 4. In a Tekton Pipeline

Snyk has a set of [Tekton Tasks](https://github.com/garethr/snyk-tekton) which can be used to check for vulnerabilities in
your pipelines. Configuration is as simple as adding a step to your pipeline definition and setting a secret with the `SNYK_TOKEN`. 

```yaml
- name: snyk
  taskRef:
    name: snyk-python
  resources:
    inputs:
      - name: source
        resource: source-rep
```

From the pipeline above you should see the Snyk output in the logs:

```console
$ tkn pipelinerun logs snyky-pipeline-run-xrg96 -f -n default
...
[snyk : snyk] All dependencies are now up-to-date!
[snyk : snyk]
[snyk : snyk] Testing /workspace/source...
[snyk : snyk]
[snyk : snyk] Tested 7 dependencies for known issues, found 2 issues, 2 vulnerable paths.
[snyk : snyk]
[snyk : snyk]
[snyk : snyk] Issues with no direct upgrade or patch:
[snyk : snyk]   ✗ Improper Input Validation [High Severity][https://snyk.io/vuln/SNYK-PYTHON-FLASK-42185] in flask@0.12
[snyk : snyk]   This issue was fixed in versions: 0.12.3
[snyk : snyk]   ✗ Denial of Service (DOS) [High Severity][https://snyk.io/vuln/SNYK-PYTHON-FLASK-451637] in flask@0.12
[snyk : snyk]   This issue was fixed in versions: 1.0
[snyk : snyk]
[snyk : snyk]
[snyk : snyk]
[snyk : snyk] Organization:      garethr
[snyk : snyk] Package manager:   pip
[snyk : snyk] Target file:       Pipfile
[snyk : snyk] Open source:       no
[snyk : snyk] Project path:      /workspace/source
[snyk : snyk] Licenses:          enabled
[snyk : snyk
```

### 5. Using Docker

You'll need a valid `SNYK_TOKEN` environment variable set to use Snyk via the [Snyk Docker images](https://github.com/snyk/snyk-images).

```console
docker run --rm -it --env SNYK_TOKEN -v $(pwd):/app snyk/snyk:python
```

For more advanced usecases you can copy Snyk into your image and use it as part of a build. You can use:

```
COPY --from=snyk/snyk:linux /usr/local/bin/snyk /usr/local/bin/snyk
```

Or if using an Alpine image use:

```dockerfile
RUN apk add --no-cache libstdc+
COPY --from=snyk/snyk:alpine /usr/local/bin/snyk /usr/local/bin/snyk
```

You can see an example of this pattern in the `Dockerfile`, and you can run it like so:

```console
$ docker build --build-arg SNYK_TOKEN --target Security .
[+] Building 21.2s (19/19) FINISHED
 => [internal] load build definition from Dockerfile                                                                     0.0s
 => => transferring dockerfile: 37B                                                                                      0.0s
 => [internal] load .dockerignore                                                                                        0.0s
 => => transferring context: 2B                                                                                          0.0s
 => [internal] load metadata for docker.io/library/python:3.7-alpine3.8                                                  0.0s
 => CACHED FROM docker.io/snyk/snyk:alpine                                                                               0.0s
 => => resolve docker.io/snyk/snyk:alpine                                                                                1.2s
 => FROM docker.io/instrumenta/conftest:latest                                                                           0.0s
 => [pipenv 1/2] FROM docker.io/library/python:3.7-alpine3.8                                                             0.0s
 => [internal] load build context                                                                                        0.1s
 => => transferring context: 116.61kB                                                                                    0.1s
 => CACHED [pipenv 2/2] RUN pip3 install pipenv                                                                          0.0s
 => CACHED [parent 1/4] WORKDIR /app                                                                                     0.0s
 => CACHED [parent 2/4] COPY Pipfile /app/                                                                               0.0s
 => CACHED [parent 3/4] COPY Pipfile.lock /app/                                                                          0.0s
 => CACHED [parent 4/4] RUN apk add --no-cache --update git=2.18.1-r0                                                    0.0s
 => CACHED [dev-base 1/3] COPY --from=instrumenta/conftest /conftest /usr/local/bin/conftest                             0.0s
 => CACHED [dev-base 2/3] RUN pipenv install --dev                                                                       0.0s
 => [dev-base 3/3] COPY . /app                                                                                           0.2s
 => [security 1/4] RUN apk add --no-cache libstdc++                                                                      1.5s
 => [security 2/4] COPY --from=snyk/snyk:alpine /usr/local/bin/snyk /usr/local/bin/snyk                                  0.2s
 => [security 3/4] RUN pipenv update                                                                                    16.0s
 => ERROR [security 4/4] RUN snyk test                                                                                   3.1s
------
 > [security 4/4] RUN snyk test:
#19 2.716
#19 2.716 Testing /app...
#19 2.716
#19 2.716 Tested 7 dependencies for known issues, found 2 issues, 2 vulnerable paths.
#19 2.716
#19 2.716
#19 2.716 Issues with no direct upgrade or patch:
#19 2.716   ✗ Improper Input Validation [High Severity][https://snyk.io/vuln/SNYK-PYTHON-FLASK-42185] in flask@0.12
#19 2.716   This issue was fixed in versions: 0.12.3
#19 2.716   ✗ Denial of Service (DOS) [High Severity][https://snyk.io/vuln/SNYK-PYTHON-FLASK-451637] in flask@0.12
#19 2.716   This issue was fixed in versions: 1.0
#19 2.716
#19 2.716
#19 2.716
#19 2.716 Organization:      garethr
#19 2.716 Package manager:   pip
#19 2.716 Target file:       Pipfile
#19 2.716 Open source:       no
#19 2.716 Project path:      /app
#19 2.716 Licenses:          enabled
#19 2.717
------
failed to solve with frontend dockerfile.v0: failed to build LLB: executor failed running [/bin/sh -c snyk test]: runc did not terminate sucessfull
```

## Installation

The full set of examples requires several tools to be installed:

* [Conftest](https://github.com/instrumenta/conftest)
* Docker
* [Helm](https://helm.sh/)
* [Conftest plugin for Helm](https://github.com/instrumenta/helm-conftest)
* Kubernetes
* [Pipenv](https://github.com/pypa/pipenv)
* Python 3.7+
* [Snyk](https://snyk.io)
* [Tilt](https://tilt.dev)
* [`tkn`](https://github.com/tektoncd/cli) (The Tekton CLI) 
