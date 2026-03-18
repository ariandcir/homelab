# ADR 0005: Organize Kubernetes resources by clusters/infrastructure/apps

- Status: Proposed
- Date: 2026-03-18

## Context

We need a clear GitOps structure that separates cluster overlays, shared platform components, and applications.

## Decision

Adopt:
- `kubernetes/clusters/` for entrypoints and overlays
- `kubernetes/infrastructure/` for shared controllers/components
- `kubernetes/apps/` for app workloads

## Consequences

- Easier ownership and blast-radius boundaries.
- Requires disciplined layering and kustomization hygiene.

> TODO(gitops): define naming conventions for Flux Kustomization objects.
