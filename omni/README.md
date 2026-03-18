# Omni cluster templates

Cluster definitions are stored as Omni cluster templates and applied with `omnictl`.

## Templates in this repository

- `omni/templates/hub-prod/cluster.yaml` - production hub example template.
- `omni/templates/hub-dr/cluster.yaml` - disaster recovery hub example template.

Each template includes dedicated patch directories for:

- `patches/common/` - shared machine-level settings.
- `patches/controlplane/` - control plane specific settings.
- `patches/worker/` - worker specific settings.

> These templates are provider-neutral by design. They include placeholders for either machine classes or manual machine UUID allocation and do not embed secrets.

## Workflow: validate -> diff -> sync -> status

Use this sequence for safe, reviewable Omni operations.

### 1) Validate

Run local structural checks first, then optional Omni schema validation:

```bash
./scripts/render-cluster-template.sh omni/templates/hub-prod/cluster.yaml
./scripts/render-cluster-template.sh omni/templates/hub-dr/cluster.yaml
```

### 2) Diff

Preview changes before applying:

```bash
omnictl cluster template diff --file omni/templates/hub-prod/cluster.yaml
omnictl cluster template diff --file omni/templates/hub-dr/cluster.yaml
```

### 3) Sync

Apply desired state after review:

```bash
omnictl cluster template sync --file omni/templates/hub-prod/cluster.yaml
omnictl cluster template sync --file omni/templates/hub-dr/cluster.yaml
```

### 4) Status

Confirm cluster and machine health after sync:

```bash
omnictl cluster status hub-prod
omnictl cluster status hub-dr
```

## Security notes

- Keep secrets out of template YAML and patches.
- Use external secret workflows (`sops`, vault, or cloud secret stores) for sensitive values.
- Validate changes in pull requests before running `sync`.
