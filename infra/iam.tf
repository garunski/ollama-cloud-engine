# IAM
resource "aws_iam_role" "ollama_cloudwatch_role" {
  name = "${var.instance_name}-cloudwatch-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy" {
  role       = aws_iam_role.ollama_cloudwatch_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ollama_cloudwatch_profile" {
  name = "${var.instance_name}-cloudwatch-profile"
  role = aws_iam_role.ollama_cloudwatch_role.name
}


