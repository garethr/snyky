workflow "Testing" {
  on = "push"
  resolves = ["snyk-test", "lint"]
}

action "snyk-test" {
  uses = "docker://snyk/snyk-cli:python-3"
  secrets = ["SNYK_TOKEN", "SNYK_ORG"]
  env = {
    PROJECT_FOLDER = "/github/workspace"
    ENV_FLAGS = "--org=${SNYK_ORK}"
    PROJECT_PATH  = "/github/workspace"
  }
}

action "lint" {
  uses = "actions/docker/cli@master"
  args = "run -i hadolint/hadolint hadolint - < Dockerfile"
}

action "build" {
  uses = "actions/docker/cli@master"
  args = "build -t sample ."
}
