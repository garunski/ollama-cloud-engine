variable "gcp_project" {
  description = "GCP project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "gcp_zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "instance_name" {
  description = "Instance name for the Ollama server"
  type        = string
  default     = "ollama-llm-server"
}

variable "tailscale_auth_key" {
  description = "Tailscale auth key"
  type        = string
  sensitive   = true
}

variable "model_choice" {
  description = "Ollama model to deploy"
  type        = string
}

variable "enable_debug" {
  description = "Enable debug logging for Ollama"
  type        = bool
  default     = false
}


