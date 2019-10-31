
IMAGE := "garethr/snyky"
NAME := "snyky"
BUILD = docker build

default: test

check-buildkit:
ifndef DOCKER_BUILDKIT
	$(error You must enable Buildkit for Docker, by setting DOCKER_BUILDKIT=1)
endif

check-snyk-token:
ifndef SNYK_TOKEN
	$(error You must have a SNYK_TOKEN to enable the snyk tasks1)
endif

build: check-buildkit
	@$(BUILD) -t $(IMAGE) ../

test: check-buildkit
	@$(BUILD) --target Test ../

snyk: check-buildkit check-snyk-token
	@$(BUILD) --build-arg SNYK_TOKEN --target Security ../

policy:
	@$(BUILD) --target Policy ../

.PHONY: build test snyk policy
