locals {
  model_configs = {
    "codellama:7b-code" = {
      instance_type = "g5.xlarge"
      volume_size   = 100
    }
    "codellama:13b-code" = {
      instance_type = "g5.2xlarge"
      volume_size   = 150
    }
    "codellama:34b-code" = {
      instance_type = "g5.4xlarge"
      volume_size   = 200
    }
    "qwen2.5-coder:32b" = {
      instance_type = "g5.4xlarge"
      volume_size   = 200
    }
    "mistralai/Mistral-7B-Instruct-v0.1" = {
      instance_type = "g5.xlarge"
      volume_size   = 100
    }
    "deepseek-coder:6.7b-base" = {
      instance_type = "g5.xlarge"
      volume_size   = 100
    }
    "llama3:8b-instruct-q5_1" = {
      instance_type = "g5.xlarge"
      volume_size   = 100
    }
  }

  # subnet_id will be created below and referenced directly in main.tf
}


