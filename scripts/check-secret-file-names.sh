#!/usr/bin/env bash
set -euo pipefail

# Ensure Kubernetes Secret manifests are committed with encrypted naming.

bad_files="$(rg --files \
  --glob '*.yaml' \
  --glob '*.yml' \
  --glob '!*.sops.yaml' \
  --glob '!*.sops.yml' \
  --glob '!*.example' \
  kubernetes flux infra | while read -r file; do
    if rg --quiet '^kind:\s*Secret$' "$file"; then
      echo "$file"
    fi
  done)"

if [[ -n "${bad_files}" ]]; then
  echo "Secret manifests must use encrypted filename suffix '*.secret.sops.yaml':"
  echo "${bad_files}"
  exit 1
fi

echo "Secret filename conventions look good."
