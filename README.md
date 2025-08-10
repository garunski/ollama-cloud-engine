# ollama-cloud-engine
A minimal, one-environment OpenTofu setup to deploy an Ollama LLM server on AWS with Tailscale-only access and CloudWatch logging. Orchestrate via Task either with a Docker all-in-one image or local CLIs.

## Before you start
- Access model: SSH is disabled. The instance has no public IP. All access happens over the Tailscale overlay using your ACLs.
- AWS credentials: Make sure your local AWS CLI is configured in `~/.aws` (profiles, SSO, etc.). Docker workflows mount this directory read-only.
- Required input: a Tailscale Auth Key (ephemeral recommended), either directly or from AWS SSM Parameter Store.

Required variables (choose one for Tailscale key):
- `TF_VAR_tailscale_auth_key`
- `TF_VAR_tailscale_auth_param_name` (SecureString in SSM)

Optional variables (defaults exist):
- `TF_VAR_instance_name`, `TF_VAR_aws_region`, `TF_VAR_model_choice`, `TF_VAR_enable_debug`
- `TF_VAR_aws_profile` (defaults to `default`)

Tip (AWS SSO): If you use SSO, run `aws sso login --profile <name>` on your machine first. The Docker workflow will use the cached SSO tokens from `~/.aws`.

## Option A: Docker all-in-one image (recommended for consistency)
This uses a single Docker image that includes OpenTofu, AWS CLI, Infracost, and Tailscale CLI. Your `~/.aws` directory is mounted in read-only mode.

1) Create a `vars.env` file in the repo root with your inputs (one per line):
```
TF_VAR_tailscale_auth_key=tskey-...        # or TF_VAR_tailscale_auth_param_name=/path/to/param
TF_VAR_aws_profile=default                 # optional
TF_VAR_aws_region=us-east-1                # optional
```
2) Build the tools image (first time only):
```sh
task docker:build
```
3) Create the environment and see cost estimate:
```sh
task docker:create
```
4) Instance lifecycle:
```sh
task docker:status
task docker:start
task docker:stop
```
5) Destroy when finished:
```sh
task docker:destroy
```

## Option B: Local CLI (macOS)
Use Brew-installed CLIs directly on your machine.

1) Install tools:
```sh
task cli:setup:mac
```
2) Export variables (or put them in `terraform.tfvars`):
```sh
export TF_VAR_tailscale_auth_key="tskey-..."   # or: export TF_VAR_tailscale_auth_param_name="/path/to/param"
export TF_VAR_aws_profile="myprofile"          # optional; defaults to 'default'
```
3) Create the environment and see cost estimate:
```sh
task cli:create
```
4) Instance lifecycle:
```sh
task cli:status
task cli:start
task cli:stop
```
5) Destroy when finished:
```sh
task cli:destroy
```

## What gets created
- A dedicated VPC with a private subnet and route to the internet via an Internet Gateway (for package installs, etc.)
- Security Group with no inbound rules (Tailscale-only); egress open by default
- An EC2 instance that installs Ollama, Tailscale, and CloudWatch Agent, then pulls the selected model
- CloudWatch Log Group for basic logging
- Infracost runs against the OpenTofu plan JSON and prints an estimated cost

## Notes
- Docker tasks read your AWS config from `~/.aws`. No credentials are baked into the image.
- Tailscale Auth Key can be ephemeral or stored in SSM (recommended to avoid secrets in TF state). If neither is present, provisioning fails early.


