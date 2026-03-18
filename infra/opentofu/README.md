# OpenTofu Skeleton (Provider-Agnostic)

This directory contains a provider-agnostic OpenTofu skeleton for two environments:

- `environments/prod`
- `environments/dr`

And reusable interface-first modules:

- `modules/network`
- `modules/firewall`
- `modules/dns`
- `modules/vm`

## Design goals

- Keep module interfaces stable regardless of cloud/provider choice.
- Avoid hardcoding a provider in shared modules.
- Support manual provisioning workflows when no provider API exists.
- Use S3-compatible remote state with encryption and locking enabled.

## Layout

```text
infra/opentofu/
  modules/
    network/
    firewall/
    dns/
    vm/
  environments/
    prod/
    dr/
```

## Usage

1. Enter an environment directory (for example `environments/prod`).
2. Copy `backend.hcl.example` to a private `backend.hcl` and set values.
3. Copy `terraform.tfvars.example` to `terraform.tfvars` and set values.
4. Initialize and validate:

   ```bash
   tofu init -backend-config=backend.hcl
   tofu fmt -check -recursive
   tofu validate
   tofu plan -out=tfplan
   ```

5. If you have provider-specific implementation modules, wire them in a separate stack.
6. If you do not have a provider API, follow the manual provisioning README in each environment.

## Safety

- This repository does **not** auto-apply infrastructure changes.
- Plans are generated explicitly via `tofu plan`.
- Apply must be manually run by an operator in a controlled process.
