# Flux GitOps layout

- `clusters/` entrypoints for each cluster.
- `infrastructure/` shared controllers/config.
- `apps/` app bases and cluster overlays.

> TODO: bootstrap Flux separately and point it at this repository path for each cluster.
