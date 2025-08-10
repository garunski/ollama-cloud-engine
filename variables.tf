variable "instance_name" {
  description = "The name of the EC2 instance."
  type        = string
  default     = "Ollama-LLM-Server"
}


variable "aws_region" {
  description = "The AWS region to deploy in."
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "The named AWS profile from local credentials to use."
  type        = string
  default     = "default"
}

 

variable "model_choice" {
  description = "The chosen Ollama model for deployment."
  type        = string
  validation {
    condition = contains([
      "codellama:7b-code",
      "codellama:13b-code", 
      "codellama:34b-code",
      "qwen2.5-coder:32b",
      "mistralai/Mistral-7B-Instruct-v0.1",
      "deepseek-coder:6.7b-base",
      "llama3:8b-instruct-q5_1"
    ], var.model_choice)
    error_message = "Model choice must be one of the supported models."
  }
}

variable "enable_debug" {
  description = "Enable debug logging for Ollama."
  type        = bool
  default     = false
}

variable "tailscale_auth_key" {
  description = "The Tailscale authentication key for the new node."
  type        = string
  sensitive   = true
  default     = ""
}

variable "tailscale_auth_param_name" {
  description = "Optional: SSM Parameter Store name that holds the Tailscale auth key (SecureString). If provided, this will be used instead of embedding the key in state."
  type        = string
  default     = ""
}

 


