# OpenTofu Root

This directory contains OpenTofu code for external infrastructure dependencies.

## Conventions

- Keep reusable modules in `modules/`.
- Keep per-environment stacks in `environments/`.
- Avoid placing provider credentials in this repository.

> TODO(iac): document first target providers and remote state backend.
