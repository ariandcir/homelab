# Flux Reconciliation Runbook

1. Verify manifests are merged on the main branch.
2. Trigger reconciliation:
   - `flux reconcile source git platform`
   - `flux reconcile kustomization cluster-lab --with-source`
3. Check health and events for failures.

> TODO(gitops): pin canonical Flux object names used by this repository.
