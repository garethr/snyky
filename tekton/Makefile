
default: tekton-run

check-snyk-token:
ifndef SNYK_TOKEN
	$(error You must have a SNYK_TOKEN to enable the snyk tasks1)
endif

tekton-install: tekton-conftest tekton-snyk
	@kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
	@kubectl apply -f https://github.com/tektoncd/dashboard/releases/download/v0.2.0/release.yaml


tekton-conftest:
	@kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/conftest/conftest.yaml
	@kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/master/conftest/helm-conftest.yaml

tekton-snyk: check-snyk-token
	@kubectl apply -f https://raw.githubusercontent.com/garethr/snyk-tekton/master/python/python.yaml
	@kubectl create secret generic snyk --from-literal=token=$(SNYK_TOKEN)

tekton-dashboard:
	@kubectl --namespace tekton-pipelines port-forward svc/tekton-dashboard 9097:9097

tekton-pipeline:
	@kubectl apply -f pipeline.yaml

tekton-run:
	@tkn pipeline start snyky-pipeline

tekton-uninstall:
	@kubectl delete -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml


.PHONY: tekton-install tekton-conftest tekton-snyk tekton-dashboard tekton-pipeline tekton-run tekton-uninstall
