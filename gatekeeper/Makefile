
KUBECTL = kubectl
APPLY = $(KUBECTL) apply -f

build: $(CURDIR)/../policy/SecurityControls.yaml

$(CURDIR)/../policy/SecurityControls.yaml: $(CURDIR)/../policy/SecurityControls.rego
	pk build $(abspath $(CURDIR)/../policy/SecurityControls.rego)

init:
	@$(APPLY) $(CURDIR)/sync.yaml
	@$(APPLY) $(CURDIR)/../policy/SecurityControls.yaml
	@$(APPLY) $(CURDIR)/enforce.yaml
	@$(APPLY) $(CURDIR)/audit.yaml

update: build
	@$(APPLY) $(CURDIR)/../policy/SecurityControls.yaml

enforce:
	@$(KUBECTL) --namespace enforce apply -f $(CURDIR)/deployment.yaml

seed:
	@$(KUBECTL) --namespace audit apply -f $(CURDIR)/deployment.yaml

audit:
	@$(KUBECTL) get SecurityControls audit-deployment-and-pod-security-controls -o yaml


.PHONY: build init update enforce seed audit
