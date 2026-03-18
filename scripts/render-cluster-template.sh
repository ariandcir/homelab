#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Render and safely validate an Omni cluster template.

Usage:
  ./scripts/render-cluster-template.sh <template-file>

Example:
  ./scripts/render-cluster-template.sh omni/templates/hub-prod/cluster.yaml
USAGE
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -ne 1 ]]; then
  echo "error: expected exactly one template file path" >&2
  usage
  exit 1
fi

template_file="$1"

if [[ ! -f "$template_file" ]]; then
  echo "error: template file not found: $template_file" >&2
  exit 1
fi

echo "==> Rendering template (verbatim): $template_file"
cat "$template_file"

echo
echo "==> Safe structural validation"
if command -v yq >/dev/null 2>&1; then
  yq eval 'select(has("kind")) | .kind' "$template_file" >/dev/null
  echo "yq: OK (all documents parse and include kind where expected)"
else
  echo "yq: skipped (not installed)"
fi

echo
echo "==> Optional Omni validation"
if command -v omnictl >/dev/null 2>&1; then
  if omnictl cluster template validate --file "$template_file"; then
    echo "omnictl validate: OK"
  else
    echo "omnictl validate: failed (review Omni context, schema, or template content)" >&2
    exit 1
  fi
else
  echo "omnictl: skipped (not installed)"
fi
