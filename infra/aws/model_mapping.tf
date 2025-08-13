locals {
  model_instance_map = {
    "codellama:7b-code"                  = "g5.xlarge"
    "mistral" = "g5.xlarge"
    "deepseek-coder:6.7b-base"           = "g5.xlarge"
    "llama3:8b-instruct-q5_1"            = "g5.xlarge"
    "codellama:13b-code"                 = "g5.2xlarge"
    "qwen2.5-coder:32b"                  = "g6e.xlarge"
    "codellama:34b-code"                 = "g6e.xlarge"
  }

  model_volume_gb_map = {
    "codellama:7b-code"                  = 100
    "mistral" = 100
    "deepseek-coder:6.7b-base"           = 100
    "llama3:8b-instruct-q5_1"            = 100
    "codellama:13b-code"                 = 150
    "qwen2.5-coder:32b"                  = 200
    "codellama:34b-code"                 = 200
  }

  selected_instance_type  = lookup(local.model_instance_map, var.model_choice)
  selected_volume_size_gb = lookup(local.model_volume_gb_map, var.model_choice)
}


