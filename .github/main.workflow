workflow "Testing" {
  on = "push"
  resolves = ["security", "lint"]
}

action "security" {
  uses = "actions/docker/cli@master"
  secrets = ["SNYK_TOKEN"]
  args = "build --build-arg SNYK_TOKEN --target Security ."
}

action "lint" {
  uses = "actions/docker/cli@master"
  args = "run -i hadolint/hadolint hadolint - < Dockerfile"
}

action "build" {
  uses = "actions/docker/cli@master"
  args = "build -t sample ."
}
