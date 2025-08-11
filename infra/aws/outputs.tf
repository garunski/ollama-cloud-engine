output "instance_id" {
  description = "The ID of the EC2 instance."
  value       = aws_instance.ollama_server.id
}

output "private_ip" {
  description = "The private IP address of the EC2 instance."
  value       = aws_instance.ollama_server.private_ip
}

output "tailscale_name" {
  description = "The Tailscale hostname for the EC2 instance."
  value       = var.instance_name
}

output "security_group_id" {
  description = "The ID of the created security group."
  value       = aws_security_group.ollama_sg.id
}

output "cloudwatch_log_group" {
  description = "The CloudWatch log group name for monitoring."
  value       = aws_cloudwatch_log_group.ollama_log_group.name
}

output "ollama_url" {
  description = "The Ollama API URL (accessible via Tailscale)."
  value       = "http://${var.instance_name}:11434"
}

output "ssh_command" {
  description = "SSH command to connect to the instance via Tailscale."
  value       = "SSH disabled; use Tailscale connectivity and ACLs"
}


