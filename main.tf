# --- Networking: Create a dedicated VPC and private subnet ---
resource "aws_vpc" "ollama_vpc" {
  cidr_block           = "10.42.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.instance_name}-vpc"
  }
}

resource "aws_internet_gateway" "ollama_igw" {
  vpc_id = aws_vpc.ollama_vpc.id
  tags = {
    Name = "${var.instance_name}-igw"
  }
}

resource "aws_subnet" "ollama_subnet" {
  vpc_id                  = aws_vpc.ollama_vpc.id
  cidr_block              = "10.42.1.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.instance_name}-subnet"
  }
}

resource "aws_route_table" "ollama_rt" {
  vpc_id = aws_vpc.ollama_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ollama_igw.id
  }

  tags = {
    Name = "${var.instance_name}-rt"
  }
}

resource "aws_route_table_association" "ollama_rta" {
  subnet_id      = aws_subnet.ollama_subnet.id
  route_table_id = aws_route_table.ollama_rt.id
}

# Get the latest Ubuntu 22.04 LTS AMI with GPU support
data "aws_ami" "ubuntu_gpu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Optional: fetch Tailscale auth key from SSM to avoid storing secret in TF state
data "aws_ssm_parameter" "tailscale_auth" {
  count = var.tailscale_auth_param_name != "" ? 1 : 0
  name  = var.tailscale_auth_param_name
  with_decryption = true
}

# --- Security Group ---
resource "aws_security_group" "ollama_sg" {
  name_prefix = "${var.instance_name}-sg"
  vpc_id      = aws_vpc.ollama_vpc.id
  description = "Security group for Ollama LLM server"

  # No inbound rules; Tailscale overlay provides access

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name = "${var.instance_name}-sg"
  }
}

# --- CloudWatch Log Group Resource ---
resource "aws_cloudwatch_log_group" "ollama_log_group" {
  name              = "/aws/ec2/${var.instance_name}"
  retention_in_days = 30
  tags = {
    Name = "${var.instance_name}-log-group"
  }
}

# --- CloudWatch Agent Configuration JSON ---
locals {
  cloudwatch_agent_config = jsonencode({
    "logs" = {
      "logs_collected" = {
        "files" = {
          "collect_list" = [
            {
              "file_path"       = "/home/ubuntu/.ollama/logs/server.log",
              "log_group_name"  = aws_cloudwatch_log_group.ollama_log_group.name,
              "log_stream_name" = "{instance_id}-ollama"
            },
            {
              "file_path"       = "/var/log/cloud-init-output.log",
              "log_group_name"  = aws_cloudwatch_log_group.ollama_log_group.name,
              "log_stream_name" = "{instance_id}-cloud-init"
            }
          ]
        }
      }
    }
  })
}

# --- IAM Role and Policy for CloudWatch Agent ---
resource "aws_iam_role" "ollama_cloudwatch_role" {
  name = "${var.instance_name}-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy" {
  role       = aws_iam_role.ollama_cloudwatch_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ollama_cloudwatch_profile" {
  name = "${var.instance_name}-cloudwatch-profile"
  role = aws_iam_role.ollama_cloudwatch_role.name
}

# --- EC2 Instance Resource ---
resource "aws_instance" "ollama_server" {
  ami                         = data.aws_ami.ubuntu_gpu.id
  instance_type               = local.model_configs[var.model_choice].instance_type
  vpc_security_group_ids      = [aws_security_group.ollama_sg.id]
  subnet_id                   = aws_subnet.ollama_subnet.id
  iam_instance_profile        = aws_iam_instance_profile.ollama_cloudwatch_profile.name
  associate_public_ip_address = false

  root_block_device {
    volume_size = local.model_configs[var.model_choice].volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name = var.instance_name
  }

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
TS_AUTH_KEY="${var.tailscale_auth_key}"
if [ -z "$TS_AUTH_KEY" ]; then
  TS_AUTH_KEY="${try(data.aws_ssm_parameter.tailscale_auth[0].value, "") }"
fi
if [ -z "$TS_AUTH_KEY" ]; then
  log "ERROR: No Tailscale auth key provided. Set TF_VAR_tailscale_auth_key or tailscale_auth_param_name."
  exit 1
fi
sudo tailscale up --auth-key="$TS_AUTH_KEY" --hostname=${var.instance_name}

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


