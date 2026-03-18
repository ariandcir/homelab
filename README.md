# homelab platform monorepo

Production-shaped home-lab platform with strict separation of concerns:

- **OpenTofu** for infrastructure where provider APIs are stable.
- **Omni** for Talos cluster lifecycle.
- **Flux** for in-cluster GitOps.
- **SOPS + age** for secret material.
- **GitHub Actions** for validation and controlled reconcile/apply operations.

## Repository layout

- `docs/` - architecture docs and ADRs.
- `infra/opentofu/` - provider-agnostic IaC interfaces and environment stacks.
- `omni/templates/` - Omni cluster templates tracked in Git.
- `flux/` - Flux GitOps structure for clusters, infra controllers, and apps.
- `scripts/` - idempotent helper scripts.
- `.github/workflows/` - CI validation and controlled sync/apply.

## Quickstart

1. Install prerequisites: `opentofu`, `flux`, `sops`, `age`, `yamllint`, and `yq`.
2. Copy `.env.example` to `.env` and populate TODO values.
3. Generate an age key pair and update `.sops.yaml` recipients.
4. Validate everything:

```bash
make validate
```

## Security

- Never commit plaintext secrets.
- Commit only SOPS-encrypted manifests under `flux/**/secrets/`.
- Keep age private keys out of the repository.

## Notes

- Edge/privacy plane (NetBird exit/relay/privacy edge) is intentionally separate from Talos cluster plane in v1.
- Avoid direct `kubectl apply` in CI; use Flux reconcile operations.
