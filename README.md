# ollama-cloud-engine
A suite of tools and configurations for deploying and managing self-hosted LLM servers on AWS.

## Minimal single-environment OpenTofu via Docker

Prerequisites:
- Docker
- Local AWS CLI configured with credentials and profiles in `~/.aws` (the container mounts this read-only)

macOS setup (assumes Homebrew):
- Install Tailscale CLI: `brew install tailscale`
- Ensure AWS CLI v2 is installed: `brew install awscli`
- (Optional) Install Infracost CLI locally: `brew install infracost`

Local CLI setup:
- Install OpenTofu, Infracost, AWS CLI, and Tailscale: `task -f Taskfile.cli.yml setup:mac`

Required variables:
- Provide a Tailscale auth key via one of:
  - `TF_VAR_tailscale_auth_key` (ephemeral recommended), or
  - `TF_VAR_tailscale_auth_param_name` (SSM Parameter Store SecureString name)
- Optional: `TF_VAR_aws_profile` (defaults to `default`)

Optional variables (defaults exist): `TF_VAR_instance_name`, `TF_VAR_aws_region`, `TF_VAR_vpc_id`, `TF_VAR_subnet_id`, `TF_VAR_model_choice`, `TF_VAR_enable_debug`.

Quickstart (Tailscale-only, no SSH):
```sh
export TF_VAR_tailscale_auth_key="tskey-..."   # or: export TF_VAR_tailscale_auth_param_name="/path/to/param"
export TF_VAR_aws_profile="myprofile"   # optional; defaults to 'default'

task up
# ... when done
task down

# Use CLI-specific Taskfile
task -f Taskfile.cli.yml up
task -f Taskfile.cli.yml down

# instance lifecycle helpers (CLI)
task -f Taskfile.cli.yml instance:status
task -f Taskfile.cli.yml instance:start
task -f Taskfile.cli.yml instance:stop
```

Setup task (macOS):
```sh
task setup:mac
```
This installs Tailscale CLI and AWS CLI, and verifies Docker.

