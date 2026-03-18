# Architecture overview

## Planes

### 1) Edge/privacy plane (separate)

- Hosts NetBird exit/relay/privacy edge components.
- Managed independently from Talos clusters in v1.
- May use provider-specific workflows outside this repository scope.

### 2) Talos cluster plane

- Cluster lifecycle and desired topology modeled as Omni cluster templates in Git.
- Omni applies template changes to Talos-managed machines.

### 3) In-cluster application plane

- Flux manages Kubernetes resources from this repository.
- Reconciliation is pull-based from Git sources.

### 4) Infrastructure plane

- OpenTofu manages stable provider API resources only.
- Provider-specific implementation remains behind a provider-agnostic interface module.
- Unstable provider APIs are represented as TODOs and excluded from automated apply.

## CI/CD model

- `validate` workflow runs formatting and static validation.
- `controlled-sync` workflow is manual (`workflow_dispatch`) and performs explicit reconcile operations for Flux and OpenTofu plan/apply when approved.
- No normal-operation direct `kubectl apply` is used in CI.
