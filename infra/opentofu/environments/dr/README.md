# Disaster recovery environment (provider-agnostic)

This stack defines disaster recovery **intent** only. It does not hardcode a cloud provider.

## Remote state

1. Copy `backend.hcl.example` to `backend.hcl`.
2. Set your S3-compatible bucket/key/region/endpoints.
3. Keep `backend.hcl` out of source control.

## Plan-only workflow

```bash
tofu init -backend-config=backend.hcl
tofu fmt -check -recursive
tofu validate
tofu plan -out=tfplan
```

> Do not auto-apply. Use a controlled manual approval process before any `tofu apply`.

## Manual provisioning (no provider API)

If your platform has no API/provider:

1. Generate a plan.
2. Run `tofu output -json manual_provisioning_specs`.
3. Translate each spec (`network`, `firewall`, `dns`, `vm`) into your provider's console/CLI steps.
4. Record IDs, IPs, and ticket links in your change record.
5. If needed, update tfvars to mirror what was actually provisioned.

This keeps OpenTofu as the source of intent while execution is manual.
