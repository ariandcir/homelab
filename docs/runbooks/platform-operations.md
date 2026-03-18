# Platform Operations Runbook (Omni + Talos + Flux)

This runbook is for day-0/day-2 cluster lifecycle operations in this repository.

## Conventions

- **[AUTOMATED]** = run an exact command/script.
- **[MANUAL]** = human action in Omni UI, hardware console, or secret manager.
- Run commands from repository root: `/workspace/homelab`.

---

## 1) Create first cluster

1. **[AUTOMATED] Validate repo and template files.**

   ```bash
   make validate
   ./scripts/render-cluster-template.sh omni/templates/hub-prod/cluster.yaml
   ```

2. **[MANUAL] Edit machine IDs in `omni/templates/hub-prod/cluster.yaml`.**
   - Replace placeholder machine UUIDs under `ControlPlane.machines` and `Workers.machines` with real Omni machine UUIDs.
   - Keep three control-plane machines.

3. **[AUTOMATED] Preview changes against Omni.**

   ```bash
   omnictl cluster template diff --file omni/templates/hub-prod/cluster.yaml
   ```

4. **[AUTOMATED] Apply desired state.**

   ```bash
   omnictl cluster template sync --file omni/templates/hub-prod/cluster.yaml
   ```

5. **[AUTOMATED] Confirm cluster health.**

   ```bash
   omnictl cluster status hub-prod
   ```

---

## 2) Register machines with Omni

1. **[MANUAL] In Omni UI, create or verify a valid join token** (Settings → Join Tokens).
2. **[MANUAL] Download Omni installation media** (ISO/PXE image) from your Omni account.
3. **[MANUAL] Boot each bare-metal/VM node from the Omni media.**
4. **[AUTOMATED] Verify machines appeared in Omni state.**

   ```bash
   omnictl get machines
   ```

5. **[MANUAL] Map discovered machine UUIDs to intended roles** (control-plane vs worker), then update template YAML.

---

## 3) Sync a cluster template

1. **[AUTOMATED] Validate template syntax and Omni schema.**

   ```bash
   ./scripts/render-cluster-template.sh omni/templates/hub-prod/cluster.yaml
   ```

2. **[AUTOMATED] Review delta before apply.**

   ```bash
   omnictl cluster template diff --file omni/templates/hub-prod/cluster.yaml
   ```

3. **[AUTOMATED] Sync.**

   ```bash
   omnictl cluster template sync --file omni/templates/hub-prod/cluster.yaml
   ```

4. **[AUTOMATED] Check post-sync status.**

   ```bash
   omnictl cluster status hub-prod
   ```

---

## 4) Bootstrap Flux

> Use `hub-prod` and `kubernetes/clusters/hub-prod` for production bootstrap.

1. **[MANUAL] Ensure cluster admin `kubeconfig` is available** (from Omni UI or `omnictl kubeconfig`).
2. **[AUTOMATED] Set kube context to target cluster.**

   ```bash
   kubectl config use-context hub-prod
   ```

3. **[AUTOMATED] Bootstrap Flux to this repository path.**

   ```bash
   export GITHUB_TOKEN='<PAT with repo admin scope>'
   flux bootstrap github \
     --token-auth \
     --owner='<github-org-or-user>' \
     --repository='homelab' \
     --branch='main' \
     --path='kubernetes/clusters/hub-prod'
   ```

4. **[AUTOMATED] Verify controllers are healthy.**

   ```bash
   flux check
   flux get all -A
   ```

5. **[AUTOMATED] Commit generated `gotk-*.yaml` files if new/changed.**

   ```bash
   git add kubernetes/clusters/hub-prod/flux-system
   git commit -m "bootstrap flux for hub-prod"
   ```

---

## 5) Rotate Omni service account credentials

1. **[AUTOMATED] List service accounts and verify target account exists.**

   ```bash
   omnictl serviceaccount list
   ```

2. **[AUTOMATED] Renew service-account key.**

   ```bash
   omnictl serviceaccount renew <service-account-name>
   ```

3. **[MANUAL] Store the newly printed `OMNI_SERVICE_ACCOUNT_KEY`** in your secret manager.
4. **[MANUAL] Update CI/CD and automation secrets** to the new key.
5. **[AUTOMATED] Smoke test automation identity.**

   ```bash
   OMNI_ENDPOINT='<omni-endpoint>' \
   OMNI_SERVICE_ACCOUNT_KEY='<new-key>' \
   omnictl cluster status hub-prod
   ```

6. **[MANUAL] Invalidate old credentials** in systems still holding the prior key.

---

## 6) Restore etcd from backup

Use when control plane lost quorum or etcd is corrupted.

1. **[MANUAL] Put an incident hold on all cluster changes** (stop GitOps merges and infra automation).
2. **[AUTOMATED] Confirm etcd/control-plane failure symptoms.**

   ```bash
   talosctl --nodes <cp1-ip>,<cp2-ip>,<cp3-ip> etcd status
   kubectl get nodes
   ```

3. **[MANUAL] Retrieve latest known-good etcd snapshot file** (for example `db.snapshot`) from backup storage.
4. **[AUTOMATED] Recover etcd using a control-plane node.**

   ```bash
   talosctl --nodes <cp1-ip> bootstrap --recover-from ./db.snapshot
   ```

5. **[AUTOMATED] Re-check etcd and Kubernetes health.**

   ```bash
   talosctl --nodes <cp1-ip>,<cp2-ip>,<cp3-ip> etcd status
   kubectl get nodes
   kubectl get pods -A
   ```

6. **[AUTOMATED] Force Flux reconciliation after API recovery.**

   ```bash
   flux reconcile source git flux-system -n flux-system
   flux reconcile kustomization flux-system -n flux-system
   ```

---

## 7) Rebuild a cluster in a second provider

Use `hub-dr` template as the provider-agnostic DR target.

1. **[MANUAL] Provision replacement nodes in second provider** (network, firewall, DNS parity with prod).
2. **[MANUAL] Register those nodes with Omni** (see section 2).
3. **[MANUAL] Replace machine UUIDs in `omni/templates/hub-dr/cluster.yaml`** with newly registered DR nodes.
4. **[AUTOMATED] Validate + diff + sync DR template.**

   ```bash
   ./scripts/render-cluster-template.sh omni/templates/hub-dr/cluster.yaml
   omnictl cluster template diff --file omni/templates/hub-dr/cluster.yaml
   omnictl cluster template sync --file omni/templates/hub-dr/cluster.yaml
   omnictl cluster status hub-dr
   ```

5. **[AUTOMATED] Bootstrap Flux against DR cluster path.**

   ```bash
   kubectl config use-context hub-dr
   flux bootstrap github \
     --token-auth \
     --owner='<github-org-or-user>' \
     --repository='homelab' \
     --branch='main' \
     --path='kubernetes/clusters/hub-dr'
   ```

6. **[MANUAL] Run failover checks** (ingress/DNS, app health, secret decryption, external dependencies).

---

## 8) Recover when Omni is unavailable

Goal: keep workloads running and maintain emergency cluster-admin access while Omni control plane is down.

1. **[MANUAL] Declare Omni outage incident** and freeze template sync operations.
2. **[AUTOMATED] Verify Kubernetes API health directly (not via Omni).**

   ```bash
   kubectl --context hub-prod get nodes
   kubectl --context hub-prod get pods -A
   ```

3. **[AUTOMATED] Pause non-essential GitOps drift changes if stability is at risk.**

   ```bash
   flux --context=hub-prod suspend kustomization --all -A
   ```

4. **[MANUAL] For emergency node access, use pre-issued break-glass Talos credentials** stored in offline secret vault.
5. **[AUTOMATED] Collect triage data for Omni vendor/internal escalation.**

   ```bash
   omnictl support --cluster hub-prod --output support-hub-prod.zip
   ```

6. **[MANUAL] After Omni recovers, resume normal operations.**

7. **[AUTOMATED] Resume Flux reconciliations and validate.**

   ```bash
   flux --context=hub-prod resume kustomization --all -A
   flux --context=hub-prod get all -A
   omnictl cluster status hub-prod
   ```

---

## 9) Disaster-recovery decision tree

```text
Start
 ├─ Is Omni reachable?
 │   ├─ Yes
 │   │   ├─ Is Kubernetes API reachable?
 │   │   │   ├─ Yes -> Normal operations; reconcile drift (template diff/sync + flux reconcile)
 │   │   │   └─ No
 │   │   │      ├─ Is etcd quorum healthy? (talosctl etcd status)
 │   │   │      │   ├─ Yes -> investigate CNI/API components; avoid restore
 │   │   │      │   └─ No  -> restore etcd snapshot (Section 6)
 │   │
 │   └─ No
 │      ├─ Is Kubernetes API still reachable directly?
 │      │   ├─ Yes -> run in degraded mode (Section 8), no template sync
 │      │   └─ No
 │      │      ├─ Is recent etcd snapshot available?
 │      │      │   ├─ Yes -> restore etcd on surviving control-plane node
 │      │      │   └─ No  -> rebuild cluster in second provider (Section 7)
 │
 └─ After service restoration
     ├─ Resume Flux
     ├─ Re-sync Omni templates
     └─ Run post-incident credential rotation (Omni SA + join tokens)
```

---

## Post-incident closeout checklist

1. **[AUTOMATED] Confirm cluster health and GitOps convergence.**

   ```bash
   omnictl cluster status hub-prod
   flux --context=hub-prod get all -A
   kubectl --context hub-prod get nodes
   ```

2. **[MANUAL] Rotate any credentials exposed during incident** (Omni service accounts, join tokens, Git deploy keys).
3. **[MANUAL] Record timeline, root cause, and corrective actions** in incident tracker.
