FROM debian:bookworm-slim

ARG AWSCLI_VERSION=2.15.59
ARG TOFU_VERSION=1.7.0

ENV DEBIAN_FRONTEND=noninteractive \
    PATH=/usr/local/bin:$PATH \
    AWS_SDK_LOAD_CONFIG=1

WORKDIR /work

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates curl unzip gnupg lsb-release bash git jq \
       tailscale \
    && rm -rf /var/lib/apt/lists/*

# Install AWS CLI v2
RUN curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-aarch64-${AWSCLI_VERSION}.zip" -o /tmp/awscliv2.zip \
    && unzip -q /tmp/awscliv2.zip -d /tmp \
    && /tmp/aws/install \
    && rm -rf /tmp/aws /tmp/awscliv2.zip

# Install OpenTofu
RUN curl -fsSL https://get.opentofu.org/install-opentofu.sh | TOFU_VERSION=${TOFU_VERSION} sh -

# Install Infracost
RUN curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh

# Helper scripts
RUN mkdir -p /usr/local/bin/scripts

# Script: create -> init, plan, show-json, apply, cost
RUN cat > /usr/local/bin/scripts/create.sh <<'EOS'
#!/usr/bin/env bash
set -euo pipefail
cd /work
mkdir -p .tfplan
tofu init
tofu plan -out .tfplan/plan.tfplan
tofu show -json .tfplan/plan.tfplan > .tfplan/plan.json
tofu apply -auto-approve .tfplan/plan.tfplan
infracost breakdown --path .tfplan/plan.json
EOS

# Script: destroy
RUN cat > /usr/local/bin/scripts/destroy.sh <<'EOS'
#!/usr/bin/env bash
set -euo pipefail
cd /work
tofu destroy -auto-approve
EOS

# Script: start
RUN cat > /usr/local/bin/scripts/start.sh <<'EOS'
#!/usr/bin/env bash
set -euo pipefail
cd /work
IID=$(tofu output -raw instance_id 2>/dev/null || true)
if [ -z "$IID" ]; then echo "Instance ID not found. Apply first."; exit 1; fi
aws ec2 start-instances --profile ${TF_VAR_aws_profile:-default} --region ${TF_VAR_aws_region:-us-east-1} --instance-ids "$IID"
EOS

# Script: stop
RUN cat > /usr/local/bin/scripts/stop.sh <<'EOS'
#!/usr/bin/env bash
set -euo pipefail
cd /work
IID=$(tofu output -raw instance_id 2>/dev/null || true)
if [ -z "$IID" ]; then echo "Instance ID not found. Apply first."; exit 1; fi
aws ec2 stop-instances --profile ${TF_VAR_aws_profile:-default} --region ${TF_VAR_aws_region:-us-east-1} --instance-ids "$IID"
EOS

RUN chmod +x /usr/local/bin/scripts/*.sh

ENTRYPOINT ["/bin/bash", "-lc"]
CMD ["bash"]


