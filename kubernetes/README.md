# Kubernetes GitOps Layout (Flux-oriented)

This tree uses a **Kustomize-first**, Flux-friendly structure with clear layering:

- `clusters/<cluster>/flux-system` — Flux bootstrap artifacts (`gotk-*`) and namespace.
- `clusters/<cluster>/infrastructure` — cluster-selected infrastructure components.
- `clusters/<cluster>/apps` — cluster-selected application workloads.
- `infrastructure/base/*` — reusable, generic platform building blocks.
- `infrastructure/<cluster>` — cluster-level composition of infrastructure bases.
- `apps/base/*` — reusable, portable workloads.
- `apps/<cluster>` — cluster-level app composition/patching.

## SOPS and age key notes

- Store sensitive manifests as `*.sops.yaml`; never commit plaintext secrets.
- Flux decrypts SOPS files when `--decryption-provider=sops` is configured in `gotk-sync.yaml`.
- Reference an age private key secret in `flux-system` (example secret name: `sops-age`).
- Keep only **age public recipients** in this repo; private keys stay outside git (e.g., secure secret manager or offline vault).
- Rotate age keys periodically and re-encrypt secrets (`sops updatekeys ...`) during rotation windows.

See also:

- `docs/adr/0002-secrets-management-sops-age.md`
- `docs/runbooks/sops-key-rotation.md`

## Scope guardrails (v1)

- Workloads remain generic and portable (no cloud-vendor lock-in assumptions).
- No stateful app complexity in this phase.
- NetBird edge functions are **not** deployed in-cluster in v1.
