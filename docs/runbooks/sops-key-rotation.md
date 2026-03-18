# SOPS Key Rotation Runbook

1. Generate a new age key pair outside the repository (default local key path: `~/.config/sops/age/keys.txt`).
2. Update recipients in your local `.sops.yaml` (based on `.sops.yaml.example` / `security/sops/.sops.yaml.example`).
3. Run `sops updatekeys -r kubernetes flux infra`.
4. Re-encrypt files and validate with `make validate-secrets`.
5. Commit only encrypted `*.secret.sops.yaml` files.

> Never commit private age keys or decrypted secret manifests.
