# Security
resource "aws_security_group" "ollama_sg" {
  name_prefix = "${var.instance_name}-sg"
  vpc_id      = aws_vpc.ollama_vpc.id
  description = "Security group for Ollama LLM server"

  # Tailscale overlay only; no inbound rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound"
  }

  tags = { Name = "${var.instance_name}-sg" }
}


