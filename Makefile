SHELL := /usr/bin/env bash

.PHONY: validate validate-yaml validate-kustomize validate-tofu validate-secrets

validate: validate-yaml validate-kustomize validate-secrets

validate-yaml:
	@echo "Linting YAML"
	@yamllint .

validate-kustomize:
	@echo "Validating kustomize overlays"
	@kustomize build kubernetes/clusters/lab >/dev/null

validate-secrets:
	@echo "Checking for plaintext secret anti-patterns"
	@./scripts/check-no-plaintext-secrets.sh

validate-tofu:
	@echo "TODO(iac): wire tofu validate once environment backend is finalized"
