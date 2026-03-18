# ADR 0004: Manage Talos cluster lifecycle with Omni

- Status: Proposed
- Date: 2026-03-18

## Context

We need a declarative workflow for Talos cluster creation, upgrades, and machine config patching.

## Decision

Use Omni as the lifecycle control plane, with desired state tracked under `omni/clusters/`.

## Consequences

- Cluster lifecycle changes are reviewable in Git.
- Additional operational dependency on Omni service availability.

> TODO(platform): document Omni tenancy model and access controls.
