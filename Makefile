SHELL := /usr/bin/env bash

TOFU_ROOT := infra/opentofu
TOFU_ENVS := $(TOFU_ROOT)/environments/prod $(TOFU_ROOT)/environments/dr

.PHONY: fmt fmt-tofu validate validate-yaml validate-kustomize validate-secrets validate-secret-hygiene validate-tofu install-hooks

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

validate-secrets: validate-secret-hygiene

validate-secret-hygiene:
	@echo "Running secret hygiene validation"
	@./scripts/validate-secret-hygiene.sh

validate-tofu:
	@echo "Validating OpenTofu environments"
	@set -euo pipefail; \
	for env in $(TOFU_ENVS); do \
	  echo "-> $$env"; \
	  tofu -chdir=$$env init -backend=false -input=false >/dev/null; \
	  tofu -chdir=$$env validate; \
	done

install-hooks:
	@git config core.hooksPath .githooks
	@echo "Configured Git hooks path to .githooks"
