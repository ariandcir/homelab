# SOPS Key Rotation Runbook

1. Generate new age key pair outside the repository.
2. Update recipients in `security/sops/.sops.yaml`.
3. Re-encrypt files and validate decryption in CI.

> TODO(security): define minimum overlap period for old/new recipients.
