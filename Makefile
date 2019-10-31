
IMAGE := "garethr/snyky"
NAME := "snyky"
BUILD = docker build

default: test

include tekton/Makefile

check-buildkit:
ifndef DOCKER_BUILDKIT
	$(error You must enable Buildkit for Docker, by setting DOCKER_BUILDKIT=1)
endif

build: check-buildkit
	@$(BUILD) -t $(IMAGE) .

test: check-buildkit
	@$(BUILD) --target Test .

snyk: check-buildkit
	@$(BUILD) --build-arg SNYK_TOKEN --target Security .

policy: generate
	@$(BUILD) --target Policy .

generate: snyky.yaml

snyky.yaml: snyky/*
	@helm template --name $(NAME) snyky > snyky.yaml

up:
	tilt up

down:
	tilt down

.PHONY: build test snyk policy generate up down
