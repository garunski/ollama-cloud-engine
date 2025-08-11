# Compute
resource "aws_instance" "ollama_server" {
  ami                         = var.custom_ami_id != "" ? var.custom_ami_id : data.aws_ami.gpu_dlami.id
  instance_type               = local.selected_instance_type
  vpc_security_group_ids      = [aws_security_group.ollama_sg.id]
  subnet_id                   = aws_subnet.private_subnet.id
  iam_instance_profile        = aws_iam_instance_profile.ollama_cloudwatch_profile.name
  associate_public_ip_address = false
  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    volume_size = local.selected_volume_size_gb
    volume_type = "gp3"
    encrypted   = true
  }

  tags = { Name = var.instance_name }

  user_data = base64encode(<<-EOF
#!/bin/bash
set -e

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a /var/log/ollama-setup.log
}

log "Starting Ollama setup..."

log "Updating system packages..."
sudo apt-get update -y
sudo apt-get install -y docker.io unzip curl amazon-cloudwatch-agent gnupg lsb-release

log "Setting up Docker..."
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu

log "Installing Ollama..."
curl -fsSL https://ollama.com/install.sh | sh

log "Configuring Ollama..."
sudo mkdir -p /etc/systemd/system/ollama.service.d/
echo "[Service]" | sudo tee /etc/systemd/system/ollama.service.d/override.conf
echo "Environment=\"OLLAMA_HOST=0.0.0.0\"" | sudo tee -a /etc/systemd/system/ollama.service.d/override.conf

if [ "${var.enable_debug}" = "true" ]; then
  log "Enabling debug logging for Ollama..."
  echo "Environment=\"OLLAMA_DEBUG=1\"" | sudo tee -a /etc/systemd/system/ollama.service.d/override.conf
fi

sudo systemctl daemon-reload
sudo systemctl restart ollama

log "Waiting for Ollama to start..."
for i in {1..30}; do
  if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    log "Ollama is ready!"
    break
  fi
  if [ $i -eq 30 ]; then
    log "ERROR: Ollama failed to start within 30 attempts"
    exit 1
  fi
  sleep 2
done

log "Configuring CloudWatch agent..."
cat << 'EOL' > /tmp/cloudwatch-config.json
${local.cloudwatch_agent_config}
EOL

log "Starting CloudWatch agent..."
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 -s -c file:/tmp/cloudwatch-config.json

if [ $? -ne 0 ]; then
  log "ERROR: CloudWatch agent failed to start"
  exit 1
fi

log "Installing Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh

  log "Connecting to Tailscale..."
  if [ -z "${var.tailscale_auth_key}" ]; then
    log "ERROR: No Tailscale auth key provided. Set TF_VAR_tailscale_auth_key."
    exit 1
  fi
  sudo tailscale up --auth-key="${var.tailscale_auth_key}" --hostname=${var.instance_name}

if [ $? -ne 0 ]; then
  log "ERROR: Tailscale authentication failed"
  exit 1
fi

log "Pulling model: ${var.model_choice}"
sudo -u ubuntu ollama pull ${var.model_choice}

if [ $? -eq 0 ]; then
  log "SUCCESS: Model ${var.model_choice} pulled successfully"
  log "Ollama server is ready at http://localhost:11434"
else
  log "ERROR: Failed to pull model ${var.model_choice}"
  exit 1
fi

log "Setup complete!"
EOF
  )
}


