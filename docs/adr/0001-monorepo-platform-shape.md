# ADR 0001: Monorepo platform shape and control planes

- **Status:** Accepted
- **Date:** 2026-03-18

## Context

The platform requires clear separation between infrastructure provisioning, cluster lifecycle, and in-cluster application management while remaining production-shaped in a home-lab setting.

## Decision

- Use OpenTofu for infrastructure resources with mature provider APIs.
- Use Omni cluster templates (stored in Git) for Talos cluster definitions.
- Use Flux for in-cluster GitOps reconciliation.
- Keep edge/privacy components (including NetBird exit/relay/privacy edge) out of Talos v1.

## Consequences

- Provider instability is surfaced via TODO placeholders instead of brittle automation.
- Cluster changes are auditable through template diffs.
- In-cluster changes follow GitOps pull model and avoid ad hoc CI applies.
