# Scripts

Operational scripts for local validation and controlled automation.

- `check-no-plaintext-secrets.sh` - detects unsafe plaintext secret patterns.
- `check-secret-file-names.sh` - enforces encrypted secret manifest naming (`*.secret.sops.yaml`).
- `validate-secret-hygiene.sh` - runs all secret hygiene checks used by CI and pre-commit.
- `render-cluster-template.sh` - renders an Omni cluster template and runs safe validation checks (`yq` parse + optional `omnictl validate`).
