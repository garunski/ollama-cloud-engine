FROM debian:bookworm-slim

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
tofu destroy -auto-approve
EOS

# Script: start
RUN cat > /usr/local/bin/scripts/start.sh <<'EOS'
#!/usr/bin/env bash
set -euo pipefail
tofu apply -auto-approve -var desired_state=running
EOS

# Script: stop
RUN cat > /usr/local/bin/scripts/stop.sh <<'EOS'
#!/usr/bin/env bash
set -euo pipefail
tofu apply -auto-approve -var desired_state=stopped
EOS

RUN chmod +x /usr/local/bin/scripts/*.sh

ENTRYPOINT ["/bin/bash", "-lc"]
CMD ["bash"]


