### Minimal Multi-Cloud Split Plan (AWS + GCP)

Keep it simple: one root per cloud, no env folders, no shared "common" or TLS modules. Duplicate what’s needed per cloud for clarity. Local state only.

---

### Principles

- Keep the current AWS behavior intact while moving it under `infra/aws`.
- Add a parallel, minimal `infra/gcp` root that we can fill in incrementally.
- No "dev/prod" directories, no shared helper modules. Prefer duplication over abstraction now.
- Local state only; no remote backend.

---

### Target Repository Layout (small and explicit)

```
infra/
  aws/
    main.tf
    providers.tf
    variables.tf
    outputs.tf
    compute.tf
    networking.tf
    security.tf
    logging.tf
    ami.tf
    model_mapping.tf

  gcp/
    main.tf
    providers.tf
    variables.tf
    outputs.tf
    compute.tf         # to be implemented
    networking.tf      # to be implemented
    security.tf        # to be implemented
    logging.tf         # to be implemented
    image.tf           # to be implemented
    model_mapping.tf   # to be implemented
```

Notes:
- We move the existing AWS `.tf` files from `infra/` into `infra/aws/` with minimal edits.
- GCP starts as a thin placeholder we can wire up later.

---

### State Strategy

- Local state kept within each cloud directory. No remote backend.

---

### Providers (one file per cloud)

- AWS: keep the existing provider config (region/profile, default tags) in `infra/aws/providers.tf`.
- GCP: minimal `google` (and `google-beta` if needed) provider in `infra/gcp/providers.tf`.

---

### Migration Steps (AWS only, no behavior change)

1) Create `infra/aws/` and move the current AWS `.tf` files into it.
2) Copy current provider block to `infra/aws/providers.tf` and keep versions in `infra/aws/main.tf` or `versions.tf`.
3) Run `tofu init` from `infra/aws/`. Plan should be a no-op.
4) After confirming plan/apply are clean, delete the old AWS files under `infra/`.

---

### GCP Scope (MVP, implement incrementally)

- Compute Engine VM with GPU (no public IP), startup script to install Tailscale + Ollama.
- VPC + subnet + firewall rules for required egress and Tailscale.
- Persistent Disk sized per model; simple machine/GPU mapping.
- Basic outputs aligned with AWS (`instance_id`, `private_ip`, `ollama_url`).

---

### Tasks and Workflow (minimal)

- Keep existing tasks. Add a single `CLOUD` param that changes working dir:
  - `task cli:plan CLOUD=aws` → runs in `infra/aws`
  - `task cli:plan CLOUD=gcp` → runs in `infra/gcp`
- No Taskfile deps, no matrix, no env folders. One root per cloud.

---

### Quotas and Prereqs (short)

- AWS: GPU vCPU quota for G families in the chosen region.
- GCP: Enable Compute Engine API and request GPU quotas in the target region/zone.

---

### Short Checklist

- [ ] Create `infra/aws` and move current AWS files there
- [ ] Copy provider/version blocks appropriately
- [ ] Remove old `infra/*.tf` after a clean plan/apply
- [ ] Scaffold `infra/gcp` with provider + placeholders
- [ ] Add `CLOUD` param to tasks to select `infra/<cloud>` working dir



