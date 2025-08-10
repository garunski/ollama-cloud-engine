<div align="center">

# ollama-cloud-engine

Spin up a production-hardened Ollama LLM server on AWS in minutes — Tailscale-only access, zero SSH, clear costs.

[![OpenTofu](https://img.shields.io/badge/IaC-OpenTofu-00B368)](https://opentofu.org) 
[![AWS](https://img.shields.io/badge/Cloud-AWS-orange)](https://aws.amazon.com) 
[![Tailscale](https://img.shields.io/badge/Access-Tailscale-28A0F0)](https://tailscale.com) 
[![Infracost](https://img.shields.io/badge/Cost-Infracost-6E56CF)](https://www.infracost.io)

</div>

### Key characteristics
- Tailscale-only access (no SSH, no public IP) for a reduced attack surface.
- Simple lifecycle via Task: consistent Docker image or local CLI.
- Cost visibility with an automatic Infracost breakdown of the plan.
- Minimal, readable OpenTofu layout without modules or multi-env complexity.

### What gets created
- Dedicated VPC (private subnet, routed egress for package installs)
- Security Group with no inbound rules (Tailscale overlay only)
- EC2 instance that installs Ollama, Tailscale, CloudWatch Agent, then pulls a model
- CloudWatch Log Group for basic observability
- Infracost cost estimate from the plan JSON

---

## Quickstart
Pick ONE path: Docker (easy/consistent) or Local CLI (fast if you already have tools).

### A) Docker (recommended)
Requires Docker only. A single tools image includes OpenTofu, AWS CLI, Infracost, and Tailscale CLI. Your `~/.aws` is mounted read-only into the container.

1) Create `vars.env`
```ini
TF_VAR_tailscale_auth_key=tskey-...
TF_VAR_model_choice=codellama:7b-code
TF_VAR_aws_profile=default                # optional
TF_VAR_aws_region=us-east-1               # optional
```

2) Build tools image (first time)
```sh
task docker:build
```

3) Create (provisions infra, prints cost)
```sh
task docker:create
```

4) Operate
```sh
task docker:status
task docker:start
task docker:stop
```

5) Destroy
```sh
task docker:destroy
```

### B) Local CLI (macOS)
Use Homebrew-installed CLIs directly.

0) Install tools
```sh
task cli:setup:mac
```

1) Set variables (or put in `terraform.tfvars`)
```sh
export TF_VAR_tailscale_auth_key="tskey-..."
export TF_VAR_model_choice="codellama:7b-code"
export TF_VAR_aws_profile="myprofile"          # optional
```

2) Create (provisions infra, prints cost)
```sh
task cli:create
```

3) Operate
```sh
task cli:status
task cli:start
task cli:stop
```

4) Destroy
```sh
task cli:destroy
```

---

## How it works (at a glance)

```mermaid
flowchart TD
  A[Task: create] --> B[OpenTofu init/plan/apply]
  B --> C[EC2 in private VPC]
  C --> D[Tailscale up \n (no public IP, no SSH)]
  C --> E[Ollama service -> CloudWatch logs]
  B --> F[Infracost on plan JSON]
```

## Inputs reference
- Required
  - `TF_VAR_tailscale_auth_key`: ephemeral key recommended
  - `TF_VAR_model_choice`: must be one of the allowed values in `variables.tf`
- Optional
  - `TF_VAR_aws_profile` (default `default`)
  - `TF_VAR_aws_region` (default `us-east-1`)
  - `TF_VAR_instance_name` (default `Ollama-LLM-Server`)
  - `TF_VAR_enable_debug` (default `false`)

## Security notes
- No inbound ports. Access via Tailscale overlay only. Keep ACLs tight.
- No SSH keys or public IPs. For break-glass, consider AWS SSM (easy to add).

## Troubleshooting
- “No Tailscale key provided”: set `TF_VAR_tailscale_auth_key`.
- “Instance ID not found”: run create/apply first.
- AWS SSO: run `aws sso login --profile <name>` locally before Docker tasks.

## License
Apache-2.0 (see `LICENSE`).


