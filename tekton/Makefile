
KUBECTL = kubectl
APPLY = $(KUBECTL) apply -f

default: tekton-run

check-snyk-token:
ifndef SNYK_TOKEN
	$(error You must have a SNYK_TOKEN to enable the snyk tasks1)
endif

init: install conftest snyk

install:
	@$(APPLY) https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
	@$(APPLY) https://github.com/tektoncd/dashboard/releases/download/v0.2.0/release.yaml

conftest:
	@$(APPLY) https://raw.githubusercontent.com/tektoncd/catalog/master/conftest/conftest.yaml
	@$(APPLY) https://raw.githubusercontent.com/tektoncd/catalog/master/conftest/helm-conftest.yaml

snyk: check-snyk-token
	@$(APPLY) https://raw.githubusercontent.com/garethr/snyk-tekton/master/python/python.yaml
	@$(KUBECTL) create secret generic snyk --from-literal=token=$(SNYK_TOKEN)

dashboard:
	@$(KUBECTL) --namespace tekton-pipelines port-forward svc/tekton-dashboard 9097:9097

pipeline:
	@$(APPLY) $(CURDIR)/pipeline.yaml

run:
	@tkn pipeline start snyky-pipeline

uninstall:
	@$(KUBECTL) delete -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml



.PHONY: init install conftest snyk dashboard pipeline run uninstall
