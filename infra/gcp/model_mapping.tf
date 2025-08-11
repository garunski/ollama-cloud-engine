locals {
  # Map models to a reasonable GCP machine type and disk size
  # Adjust as we validate GPU families/quotas
  model_machine_map = {
    "codellama:7b-code"                  = { machine = "n1-standard-8",  gpu_type = "nvidia-tesla-t4", gpu_count = 1 }
    "mistralai/Mistral-7B-Instruct-v0.1" = { machine = "n1-standard-8",  gpu_type = "nvidia-tesla-t4", gpu_count = 1 }
    "deepseek-coder:6.7b-base"           = { machine = "n1-standard-8",  gpu_type = "nvidia-tesla-t4", gpu_count = 1 }
    "llama3:8b-instruct-q5_1"            = { machine = "n1-standard-8",  gpu_type = null,               gpu_count = 0 }
    "codellama:13b-code"                 = { machine = "n1-standard-16", gpu_type = "nvidia-tesla-t4", gpu_count = 1 }
    "qwen2.5-coder:32b"                  = { machine = "a2-highgpu-1g",  gpu_type = "nvidia-tesla-a100", gpu_count = 1 }
    "codellama:34b-code"                 = { machine = "a2-highgpu-1g",  gpu_type = "nvidia-tesla-a100", gpu_count = 1 }
  }

  model_volume_gb_map = {
    "codellama:7b-code"                  = 100
    "mistralai/Mistral-7B-Instruct-v0.1" = 100
    "deepseek-coder:6.7b-base"           = 100
    "llama3:8b-instruct-q5_1"            = 100
    "codellama:13b-code"                 = 150
    "qwen2.5-coder:32b"                  = 200
    "codellama:34b-code"                 = 200
  }

  _sel = lookup(local.model_machine_map, var.model_choice)

  selected_machine_type  = _sel.machine
  selected_gpu_type      = _sel.gpu_type
  selected_gpu_count     = _sel.gpu_count
  selected_volume_size_gb = lookup(local.model_volume_gb_map, var.model_choice)
}


