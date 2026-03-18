#!/usr/bin/env bash
set -euo pipefail

# Idempotent scan for likely plaintext secret assignments in YAML files.
# TODO(security): tune regex patterns for organization-specific conventions.

matches="$(rg --line-number --glob '*.yaml' --glob '*.yml' '(password|token|secret|api[_-]?key):\s*\"?[A-Za-z0-9_\-]{8,}\"?' kubernetes omni infra security || true)"

if [[ -n "${matches}" ]]; then
  echo "Potential plaintext secrets detected:"
  echo "${matches}"
  exit 1
fi

echo "No obvious plaintext secrets found."
