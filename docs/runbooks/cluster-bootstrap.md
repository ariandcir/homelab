# Cluster Bootstrap Runbook

1. Validate repository state: `make validate`.
2. Apply OpenTofu baseline for required external dependencies.
3. Create or update Omni cluster definition in `omni/clusters/`.
4. Bootstrap Flux from `kubernetes/clusters/<cluster-name>`.

> TODO(platform): document exact Omni bootstrap command sequence for your environment.
