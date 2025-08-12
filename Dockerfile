FROM debian:bookworm-slim

ARG TOFU_VERSION=1.7.0

ENV DEBIAN_FRONTEND=noninteractive \
    PATH=/usr/local/bin:$PATH \
    AWS_SDK_LOAD_CONFIG=1

WORKDIR /work

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates curl unzip gnupg lsb-release bash git jq \
    && rm -rf /var/lib/apt/lists/*

# Install OpenTofu via APT repository
RUN curl -fsSL https://packages.opentofu.org/opentofu/tofu/gpgkey | gpg --dearmor -o /usr/share/keyrings/opentofu-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/opentofu-archive-keyring.gpg] https://packages.opentofu.org/opentofu/tofu/any/ any main" > /etc/apt/sources.list.d/opentofu.list \
    && apt-get update \
    && apt-get install -y tofu

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

# Script: status
RUN cat > /usr/local/bin/scripts/status.sh <<'EOS'
#!/usr/bin/env bash
set -euo pipefail
tofu output -raw instance_status 2>/dev/null || echo unknown
EOS

RUN chmod +x /usr/local/bin/scripts/*.sh

ENTRYPOINT ["/bin/bash", "-lc"]
CMD ["bash"]


