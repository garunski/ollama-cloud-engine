# Logging
resource "aws_cloudwatch_log_group" "ollama_log_group" {
  name              = "/aws/ec2/${var.instance_name}"
  retention_in_days = 30
  tags              = { Name = "${var.instance_name}-log-group" }
}

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
            },
            {
              "file_path"       = "/var/log/ollama-setup.log",
              "log_group_name"  = aws_cloudwatch_log_group.ollama_log_group.name,
              "log_stream_name" = "{instance_id}-setup"
            }
          ]
        }
      }
    }
  })
}


