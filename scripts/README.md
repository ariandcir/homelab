# Scripts

Operational scripts for local validation and controlled automation.

- `check-no-plaintext-secrets.sh` - detects unsafe secret anti-patterns.
- `render-cluster-template.sh` - renders an Omni cluster template and runs safe validation checks (`yq` parse + optional `omnictl validate`).

