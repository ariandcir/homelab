# SOPS + age scaffolding

## Local key locations (developer machines)

- **age private key file:** `~/.config/sops/age/keys.txt`
- **Optional override:** set `SOPS_AGE_KEY_FILE` to a custom key path.
- **Public recipient:** derive with `age-keygen -y ~/.config/sops/age/keys.txt`

## Never commit these files

- `~/.config/sops/age/keys.txt` (or any private age key file)
- `.env` files containing credentials
- Decrypted `*.secret.yaml` manifests
- Any file containing plaintext `data:` / `stringData:` values for Kubernetes Secrets

## Encrypted file naming conventions

Use these conventions consistently:

- Kubernetes/Flux secret manifests: `*.secret.sops.yaml`
- Non-secret manifests: `*.yaml`
- Do **not** use `*.secret.yaml` for committed files; that suffix implies plaintext and is blocked by validation.

Examples:

- `flux/apps/lab/demo-app/demo-app.secret.sops.yaml`
- `kubernetes/apps/lab/example/example.secret.sops.yaml`

## Suggested setup

1. Generate a local key pair (`age-keygen -o ~/.config/sops/age/keys.txt`).
2. Share only the public recipient with platform maintainers.
3. Copy `.sops.yaml.example` to `.sops.yaml` and replace recipient placeholders.
4. Encrypt new secret files with `sops --encrypt --in-place path/to/file.secret.sops.yaml`.
5. Run `make validate-secrets` before pushing.
