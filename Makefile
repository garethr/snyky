
IMAGE := "garethr/snyky"
NAME := "snyky"
BUILD = docker build

default: test

TARGET = $$(echo $@ | cut -d "-" -f 2- | sed "s/%*$$//")

check-buildkit:
ifndef DOCKER_BUILDKIT
	$(error You must enable Buildkit for Docker, by setting DOCKER_BUILDKIT=1)
endif

check-snyk-token:
ifndef SNYK_TOKEN
	$(error You must have a SNYK_TOKEN to enable the snyk tasks1)
endif

build: check-buildkit
	@$(BUILD) -t $(IMAGE) .

test: check-buildkit
	@$(BUILD) --target Test .

snyk: check-buildkit check-snyk-token
	@$(BUILD) --build-arg SNYK_TOKEN --target Security .

policy: generate
	@$(BUILD) --target Policy .

generate: snyky.yaml

$(NAME).yaml: $(NAME)/*
	@helm template --name $(NAME) $(NAME) > $(NAME).yaml

tekton-%:
	@$(MAKE) -C tekton $(TARGET)

gatekeeper-%:
	@$(MAKE) -C gatekeeper $(TARGET)

up:
	tilt up

down:
	tilt down

.PHONY: build test snyk policy generate tekton-% gatekeeper-% up down
