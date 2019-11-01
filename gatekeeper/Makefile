
KUBECTL = kubectl
APPLY = $(KUBECTL) apply -f

init:
	@$(APPLY) $(CURDIR)/sync.yaml
	@$(APPLY) $(CURDIR)/SecurityControls.yaml
	@$(APPLY) $(CURDIR)/enforce.yaml
	@$(APPLY) $(CURDIR)/audit.yaml

show:
	@$(KUBECTL) get SecurityControls deployment-and-pod-security-controls -o yaml


.PHONY: init show
