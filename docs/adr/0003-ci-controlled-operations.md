# ADR 0003: Controlled CI operations

- **Status:** Accepted
- **Date:** 2026-03-18

## Context

Automation must be safe and deterministic for a production-shaped home-lab platform.

## Decision

- CI validation runs automatically on push/PR.
- Stateful operations (Flux reconcile and OpenTofu apply) require `workflow_dispatch` and explicit environment/target inputs.
- Do not use self-hosted runners by default.
- Do not use direct `kubectl apply` in CI for normal operations.

## Consequences

- Operators have stronger change control gates.
- Slightly slower operations due to explicit approval step.
