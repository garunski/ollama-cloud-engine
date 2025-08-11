# Compute Engine VM for Ollama; no public IP, egress via Cloud NAT

locals {
  metadata_startup_script = <<-EOT
#!/bin/bash
set -e

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a /var/log/ollama-setup.log
}

log "Updating system packages..."
apt-get update -y
apt-get install -y docker.io curl jq
systemctl enable docker
systemctl start docker

log "Installing Ollama..."
curl -fsSL https://ollama.com/install.sh | sh

log "Configuring Ollama..."
mkdir -p /etc/systemd/system/ollama.service.d/
echo "[Service]" > /etc/systemd/system/ollama.service.d/override.conf
echo "Environment=\"OLLAMA_HOST=0.0.0.0\"" >> /etc/systemd/system/ollama.service.d/override.conf
if [ "${var.enable_debug}" = "true" ]; then
  echo "Environment=\"OLLAMA_DEBUG=1\"" >> /etc/systemd/system/ollama.service.d/override.conf
fi
systemctl daemon-reload
systemctl restart ollama

log "Installing Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh

if [ -z "${var.tailscale_auth_key}" ]; then
  log "ERROR: No Tailscale auth key provided. Set TF_VAR_tailscale_auth_key."
  exit 1
fi

log "Connecting to Tailscale..."
tailscale up --auth-key="${var.tailscale_auth_key}" --hostname=${var.instance_name}

log "Waiting for Ollama..."
for i in {1..30}; do
  if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    log "Ollama is ready"
    break
  fi
  if [ $i -eq 30 ]; then
    log "ERROR: Ollama failed to start"
    exit 1
  fi
  sleep 2
done

log "Pulling model: ${var.model_choice}"
ollama pull ${var.model_choice}

log "Setup complete"
EOT
}

resource "google_compute_address" "internal_ip" {
  name         = "${var.instance_name}-ip"
  address_type = "INTERNAL"
  subnetwork   = google_compute_subnetwork.private_subnet.name
  region       = var.gcp_region
}

resource "google_compute_disk" "root" {
  name  = "${var.instance_name}-root"
  type  = "pd-balanced"
  zone  = var.gcp_zone
  image = data.google_compute_image.ubuntu.self_link
  size  = local.selected_volume_size_gb
}

resource "google_compute_instance" "ollama" {
  name         = var.instance_name
  machine_type = local.selected_machine_type
  zone         = var.gcp_zone

  boot_disk {
    source = google_compute_disk.root.name
  }

  network_interface {
    subnetwork = google_compute_subnetwork.private_subnet.id
    stack_type = "IPV4_ONLY"
    network_ip = google_compute_address.internal_ip.address
    # No access_config => no public IP
  }

  metadata_startup_script = local.metadata_startup_script
  metadata = {
    install-nvidia-driver = "true"
  }

  # Manage power state only via desired_status (RUNNING|TERMINATED)
  desired_status = var.desired_state == "running" ? "RUNNING" : "TERMINATED"

  scheduling {
    on_host_maintenance = "TERMINATE"
    automatic_restart   = true
    preemptible         = false
  }

  dynamic "guest_accelerator" {
    for_each = local.selected_gpu_type == null ? [] : [1]
    content {
      type  = local.selected_gpu_type
      count = local.selected_gpu_count
    }
  }
}


