# Platform Operations Runbook (Omni + Talos + Flux)

Audience: on-call/platform operators.

Run all commands from repo root:

```bash
cd /workspace/homelab
```

Conventions used in every section:

- **[AUTOMATED]** exact command sequence.
- **[MANUAL]** human action in Omni UI, provider console, or secret manager.

---

## 1) Create first cluster (`hub-prod`)

1. **[AUTOMATED] Validate repo and template render.**

   ```bash
   make validate
   ./scripts/render-cluster-template.sh omni/templates/hub-prod/cluster.yaml
   ```

2. **[MANUAL] Populate machine UUIDs in template.**
   - Open `omni/templates/hub-prod/cluster.yaml`.
   - Set `ControlPlane.machines` to exactly 3 Omni machine UUIDs.
   - Set `Workers.machines` to all worker UUIDs.

3. **[AUTOMATED] Preview and apply the cluster template.**

   ```bash
   omnictl cluster template diff --file omni/templates/hub-prod/cluster.yaml
   omnictl cluster template sync --file omni/templates/hub-prod/cluster.yaml
   ```

4. **[AUTOMATED] Verify cluster state reached healthy.**

   ```bash
   omnictl cluster status hub-prod
   ```

---

## 2) Register machines with Omni

1. **[MANUAL] Create a join token in Omni UI.**
   - Omni UI path: **Settings → Join Tokens → Create Token**.

2. **[MANUAL] Boot each node with Omni install media.**
   - Use Omni-provided ISO/PXE.
   - Ensure node networking lets it reach Omni endpoint.

3. **[AUTOMATED] Confirm machines appeared and capture UUIDs.**

   ```bash
   omnictl get machines -o yaml > /tmp/omni-machines.yaml
   ```

4. **[MANUAL] Assign roles and update template YAML.**
   - Pick 3 stable nodes for control plane.
   - Update `omni/templates/hub-prod/cluster.yaml` machine lists.

---

## 3) Sync a cluster template (safe apply cycle)

1. **[AUTOMATED] Render/validate template.**

   ```bash
   ./scripts/render-cluster-template.sh omni/templates/hub-prod/cluster.yaml
   ```

2. **[AUTOMATED] Diff desired vs current state.**

   ```bash
   omnictl cluster template diff --file omni/templates/hub-prod/cluster.yaml
   ```

3. **[MANUAL] Review diff output for machine replacement/destructive changes.**

4. **[AUTOMATED] Apply template.**

   ```bash
   omnictl cluster template sync --file omni/templates/hub-prod/cluster.yaml
   omnictl cluster status hub-prod
   ```

---

## 4) Bootstrap Flux (`hub-prod`)

1. **[AUTOMATED] Set required environment variables from the repo remote.**

   ```bash
   export GITHUB_TOKEN="$(gh auth token)"
   export GIT_REMOTE_URL="$(git remote get-url origin)"
   export GIT_OWNER="$(basename "$(dirname "$GIT_REMOTE_URL")" .git)"
   export GIT_REPO="$(basename "$GIT_REMOTE_URL" .git)"
   ```

2. **[MANUAL] Ensure `hub-prod` kubeconfig context is available locally.**

3. **[AUTOMATED] Bootstrap Flux to the cluster path in this repo.**

   ```bash
   kubectl config use-context hub-prod
   flux bootstrap github \
     --token-auth \
     --owner="$GIT_OWNER" \
     --repository="$GIT_REPO" \
     --branch='main' \
     --path='kubernetes/clusters/hub-prod'
   ```

4. **[AUTOMATED] Validate Flux controllers and objects.**

   ```bash
   flux check
   flux get all -A
   ```

5. **[AUTOMATED] Commit bootstrap artifacts if changed.**

   ```bash
   git add kubernetes/clusters/hub-prod/flux-system
   git commit -m "bootstrap flux for hub-prod"
   ```

---

## 5) Rotate Omni service account credentials

1. **[AUTOMATED] List service accounts and rotate target account key.**

   ```bash
   omnictl serviceaccount list
   omnictl serviceaccount renew platform-automation
   ```

2. **[MANUAL] Immediately store new key in secret manager.**
   - Secret key name: `OMNI_SERVICE_ACCOUNT_KEY`.

3. **[MANUAL] Update all automation consumers.**
   - GitHub Actions secrets.
   - External schedulers/jobs.
   - Local ops vault entries.

4. **[AUTOMATED] Verify new key works.**

   ```bash
   OMNI_ENDPOINT="${OMNI_ENDPOINT}" \
   OMNI_SERVICE_ACCOUNT_KEY="${OMNI_SERVICE_ACCOUNT_KEY}" \
   omnictl cluster status hub-prod
   ```

5. **[MANUAL] Revoke old key everywhere.**

---

## 6) Restore etcd from backup

Use when API is down and etcd quorum is lost/corrupt.

1. **[MANUAL] Freeze change traffic.**
   - Stop merges touching cluster config.
   - Pause infra automation runs.

2. **[AUTOMATED] Confirm etcd/quorum failure.**

   ```bash
   talosctl --nodes <cp1-ip>,<cp2-ip>,<cp3-ip> etcd status
   kubectl --context hub-prod get nodes
   ```

3. **[MANUAL] Retrieve latest known-good snapshot** to local path `/tmp/db.snapshot`.

4. **[AUTOMATED] Recover on one control-plane node.**

   ```bash
   talosctl --nodes <cp1-ip> bootstrap --recover-from /tmp/db.snapshot
   ```

5. **[AUTOMATED] Validate control plane recovery.**

   ```bash
   talosctl --nodes <cp1-ip>,<cp2-ip>,<cp3-ip> etcd status
   kubectl --context hub-prod get nodes
   kubectl --context hub-prod get pods -A
   ```

6. **[AUTOMATED] Reconcile Flux after API is stable.**

   ```bash
   flux --context=hub-prod reconcile source git flux-system -n flux-system
   flux --context=hub-prod reconcile kustomization flux-system -n flux-system
   ```

---

## 7) Rebuild a cluster in a second provider (`hub-dr`)

1. **[MANUAL] Provision replacement nodes in provider B.**
   - Match network policy, DNS, and firewall policy from prod.

2. **[MANUAL] Register new nodes in Omni** (follow section 2).

3. **[MANUAL] Update DR template with provider-B machine UUIDs.**
   - File: `omni/templates/hub-dr/cluster.yaml`.

4. **[AUTOMATED] Render, diff, and sync DR cluster.**

   ```bash
   ./scripts/render-cluster-template.sh omni/templates/hub-dr/cluster.yaml
   omnictl cluster template diff --file omni/templates/hub-dr/cluster.yaml
   omnictl cluster template sync --file omni/templates/hub-dr/cluster.yaml
   omnictl cluster status hub-dr
   ```

5. **[AUTOMATED] Bootstrap Flux for DR cluster.**

   ```bash
   kubectl config use-context hub-dr
   flux bootstrap github \
     --token-auth \
     --owner="$GIT_OWNER" \
     --repository="$GIT_REPO" \
     --branch='main' \
     --path='kubernetes/clusters/hub-dr'
   ```

6. **[MANUAL] Execute failover checks before traffic switch.**
   - DNS cutover readiness.
   - Ingress/TLS verification.
   - App health and data-path checks.

---

## 8) Recover when Omni is unavailable

Goal: keep Kubernetes stable while Omni control plane is down.

1. **[MANUAL] Declare Omni outage and stop template sync operations.**

2. **[AUTOMATED] Confirm cluster health directly via Kubernetes API.**

   ```bash
   kubectl --context hub-prod get nodes
   kubectl --context hub-prod get pods -A
   ```

3. **[AUTOMATED] Suspend non-essential Flux reconciliations if drift risk is high.**

   ```bash
   flux --context=hub-prod suspend kustomization --all -A
   ```

4. **[MANUAL] Use break-glass Talos credentials for emergency node operations.**

5. **[AUTOMATED] Collect Omni support bundle for escalation (when API is intermittently reachable).**

   ```bash
   omnictl support --cluster hub-prod --output /tmp/support-hub-prod.zip
   ```

6. **[MANUAL] When Omni is restored, resume standard operations.**

7. **[AUTOMATED] Resume Flux and validate full convergence.**

   ```bash
   flux --context=hub-prod resume kustomization --all -A
   flux --context=hub-prod get all -A
   omnictl cluster status hub-prod
   ```

---

## 9) Disaster-recovery decision tree

```text
Incident start
 ├─ Omni reachable?
 │   ├─ Yes
 │   │   ├─ Kubernetes API reachable?
 │   │   │   ├─ Yes -> normal recovery: template diff/sync, then flux reconcile
 │   │   │   └─ No
 │   │   │      ├─ etcd quorum healthy (talosctl etcd status)?
 │   │   │      │   ├─ Yes -> repair API/CNI/control-plane components; do not restore snapshot
 │   │   │      │   └─ No  -> execute "Restore etcd from backup" (section 6)
 │   └─ No
 │      ├─ Kubernetes API reachable directly?
 │      │   ├─ Yes -> degraded mode: execute "Recover when Omni is unavailable" (section 8)
 │      │   └─ No
 │      │      ├─ Recent etcd snapshot available?
 │      │      │   ├─ Yes -> restore etcd (section 6)
 │      │      │   └─ No  -> rebuild DR cluster in second provider (section 7)
 └─ After stabilization
     ├─ Resume Flux reconciliations
     ├─ Re-sync Omni templates
     └─ Rotate Omni/join credentials
```

---

## Post-incident closeout

1. **[AUTOMATED] Validate control plane, nodes, and Flux state.**

   ```bash
   omnictl cluster status hub-prod
   kubectl --context hub-prod get nodes
   flux --context=hub-prod get all -A
   ```

2. **[MANUAL] Rotate any exposed credentials.**
   - Omni service-account keys.
   - Omni join tokens.
   - Git deploy/bot tokens used during incident.

3. **[MANUAL] Publish incident report.**
   - Timeline, root cause, blast radius, and follow-up actions.
