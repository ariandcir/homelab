SHELL := /usr/bin/env bash

TOFU_ROOT := infra/opentofu
TOFU_ENVS := $(TOFU_ROOT)/environments/prod $(TOFU_ROOT)/environments/dr

.PHONY: fmt fmt-tofu validate validate-yaml validate-kustomize validate-secrets validate-tofu

fmt: fmt-tofu

fmt-tofu:
	@echo "Formatting OpenTofu files"
	@tofu fmt -recursive $(TOFU_ROOT)

validate: validate-yaml validate-kustomize validate-secrets validate-tofu

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
	@echo "Validating OpenTofu environments"
	@set -euo pipefail; \
	for env in $(TOFU_ENVS); do \
	  echo "-> $$env"; \
	  tofu -chdir=$$env init -backend=false -input=false >/dev/null; \
	  tofu -chdir=$$env validate; \
	done
