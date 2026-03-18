# ADR 0002: Secrets management with SOPS and age

- **Status:** Accepted
- **Date:** 2026-03-18

## Context

The repository must not contain plaintext secrets and should support Git-native encrypted secret workflows.

## Decision

- Use SOPS with age recipients for secret encryption.
- Encrypt Kubernetes Secret manifests before commit.
- Store decryption keys outside of Git; inject in CI through GitHub encrypted secrets.

## Consequences

- Developers need local age + sops setup.
- CI validates encrypted manifests and fails if plaintext secret patterns are found.
