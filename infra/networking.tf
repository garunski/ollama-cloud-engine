# --- Networking ---
resource "aws_vpc" "ollama_vpc" {
  cidr_block           = "10.42.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "${var.instance_name}-vpc" }
}

resource "aws_internet_gateway" "ollama_igw" {
  vpc_id = aws_vpc.ollama_vpc.id
  tags   = { Name = "${var.instance_name}-igw" }
}

resource "aws_subnet" "ollama_subnet" {
  vpc_id                  = aws_vpc.ollama_vpc.id
  cidr_block              = "10.42.1.0/24"
  map_public_ip_on_launch = false
  tags                    = { Name = "${var.instance_name}-subnet" }
}

resource "aws_route_table" "ollama_rt" {
  vpc_id = aws_vpc.ollama_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ollama_igw.id
  }

  tags = { Name = "${var.instance_name}-rt" }
}

resource "aws_route_table_association" "ollama_rta" {
  subnet_id      = aws_subnet.ollama_subnet.id
  route_table_id = aws_route_table.ollama_rt.id
}


