workflow "Testing" {
  on = "push"
  resolves = ["snyk-code", "lint", "snyk-image"]
}

action "snyk-code" {
  uses = "docker://snyk/snyk-cli:python-3"
  secrets = ["SNYK_TOKEN", "SNYK_ORG"]
  env = {
    PROJECT_PATH  = "/github/workspace"
  }
  args = "test --org=${SNYK_ORG}"
  runs = ["sh", "-c", "/home/node/docker-python-entrypoint.sh"]

}

action "lint" {
  uses = "actions/docker/cli@master"
  args = "run -i hadolint/hadolint hadolint - < Dockerfile"
}

action "build" {
  uses = "actions/docker/cli@master"
  args = "build -t sample ."
}

action "snyk-image" {
  uses = "docker://snyk/snyk-cli:docker"
  secrets = ["SNYK_TOKEN", "SNYK_ORG"]
  env = {
    PROJECT_PATH  = "/github/workspace"
  }
  args = "test --docker sample --file=Dockerfile --org=${SNYK_ORG}"
  runs = ["sh", "-c", "/home/node/docker-entrypoint.sh"]
  needs = "build"
}

