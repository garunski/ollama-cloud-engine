# Manage and query instance state via OpenTofu only

resource "aws_ec2_instance_state" "ollama_state" {
  instance_id = aws_instance.ollama_server.id
  state       = var.desired_state
}

data "aws_instance" "ollama" {
  instance_id = aws_instance.ollama_server.id
}


