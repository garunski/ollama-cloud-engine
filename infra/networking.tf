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

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.ollama_vpc.id
  cidr_block              = "10.42.0.0/24"
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.instance_name}-public" }
}

resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.ollama_vpc.id
  cidr_block              = "10.42.1.0/24"
  map_public_ip_on_launch = false
  tags                    = { Name = "${var.instance_name}-private" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.ollama_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ollama_igw.id
  }

  tags = { Name = "${var.instance_name}-public-rt" }
}

resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags   = { Name = "${var.instance_name}-nat-eip" }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id
  tags          = { Name = "${var.instance_name}-nat" }
  depends_on    = [aws_internet_gateway.ollama_igw]
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.ollama_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = { Name = "${var.instance_name}-private-rt" }
}

resource "aws_route_table_association" "private_rta" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}


