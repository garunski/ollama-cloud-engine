// Placeholder outputs for GCP; align with AWS when implemented

output "instance_id" {
  description = "Compute instance ID"
  value       = google_compute_instance.ollama.id
}

output "private_ip" {
  description = "Private IP of the instance"
  value       = google_compute_address.internal_ip.address
}

output "ollama_url" {
  description = "Base URL for Ollama API (via Tailscale)"
  value       = "http://${var.instance_name}:11434"
}

output "instance_name" {
  description = "Instance name"
  value       = var.instance_name
}


