SHELL := /usr/bin/env bash

.PHONY: validate validate-yaml validate-tofu validate-secrets fmt fmt-tofu omni-validate

validate: fmt validate-yaml validate-tofu validate-secrets

fmt: fmt-tofu

fmt-tofu:
	@echo "Running tofu fmt recursively"
	@tofu fmt -recursive infra/opentofu

validate-yaml:
	@echo "Linting YAML"
	@yamllint .

validate-tofu:
	@echo "Validating OpenTofu stack"
	@cd infra/opentofu/environments/lab && tofu init -backend=false -input=false >/dev/null && tofu validate

validate-secrets:
	@echo "Checking for plaintext secret anti-patterns"
	@./scripts/check-no-plaintext-secrets.sh

omni-validate:
	@echo "Validating Omni template"
	@omnictl cluster template validate --file omni/templates/lab/cluster.yaml
