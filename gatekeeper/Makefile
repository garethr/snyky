
KUBECTL = kubectl
APPLY = $(KUBECTL) apply -f

init: exclude
	@$(APPLY) $(CURDIR)/sync.yaml
	@$(APPLY) $(CURDIR)/SecurityControls.yaml
	@$(APPLY) $(CURDIR)/constraint.yaml

exclude:
	$(KUBECTL) label --overwrite namespace/kube-system control-plane=1

show:
	@$(KUBECTL) get SecurityControls deployment-and-pod-security-controls -o yaml


.PHONY: init exclude show
