
NAME := "snyky"

TARGET = $$(echo $@ | cut -d "-" -f 2- | sed "s/%*$$//")

generate: snyky.yaml

$(NAME).yaml: $(NAME)/*
	@helm template --name $(NAME) $(NAME) > $(NAME).yaml

tekton-%:
	@$(MAKE) -C tekton $(TARGET)

gatekeeper-%:
	@$(MAKE) -C gatekeeper $(TARGET)

docker-%:
	@$(MAKE) -C docker $(TARGET)

up:
	tilt up

down:
	tilt down

.PHONY: generate tekton-% gatekeeper-% docker-% up down
