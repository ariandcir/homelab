#!/usr/bin/env bash
set -euo pipefail

# Detect likely plaintext secret material committed in YAML files.

# 1) High-signal key/value assignments outside encrypted files.
plain_assignments="$(rg --line-number \
  --glob '*.yaml' \
  --glob '*.yml' \
  --glob '!*.sops.yaml' \
  --glob '!*.sops.yml' \
  --glob '!.sops.yaml.example' \
  --glob '!.sops.yml.example' \
  '(password|token|secret|api[_-]?key|client[_-]?secret):\s*[^<\[{][^ ]{4,}' \
  kubernetes flux infra || true)"

# 2) Unencrypted Kubernetes Secret payload blocks in non-sops files.
secret_payloads="$(rg --files \
  --glob '*.yaml' \
  --glob '*.yml' \
  --glob '!*.sops.yaml' \
  --glob '!*.sops.yml' \
  kubernetes flux infra | while read -r file; do
    if rg --quiet '^kind:\s*Secret$' "$file" && rg --quiet '^(data|stringData):\s*$' "$file"; then
      rg --line-number '^(data|stringData):\s*$' "$file"
    fi
  done)"

if [[ -n "${plain_assignments}" || -n "${secret_payloads}" ]]; then
  echo "Potential plaintext secrets detected."
  if [[ -n "${plain_assignments}" ]]; then
    echo
    echo "Suspicious secret-like assignments:"
    echo "${plain_assignments}"
  fi
  if [[ -n "${secret_payloads}" ]]; then
    echo
    echo "Potential unencrypted Secret payload blocks:"
    echo "${secret_payloads}"
  fi
  exit 1
fi

echo "No obvious plaintext secrets found."
