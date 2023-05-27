#################################################################
# PROVIDERS
#################################################################

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
}

#################################################################
# DATA 
#################################################################

data "aws_ssm_parameter" "ami" {
  name = var.ami_ssm_parameter
}

#################################################################
# RESOURCES
#################################################################

# NETWORKING #

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = var.vpc_enable_dns_hostnames

  tags = local.common_tags
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = local.common_tags
}

resource "aws_subnet" "subnet1" {
  cidr_block              = var.subnet1_cidr_block
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = var.subnet1_map_public_ip_on_launch

  tags = local.common_tags
}

# ROUTING #

resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = local.common_tags
}

resource "aws_route_table_association" "rta-subnet1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rtb.id
}

# SECURITY GROUPS #
# Nginx security group

resource "aws_security_group" "nginx-sg" {
  name   = "nginx-sg"
  vpc_id = aws_vpc.vpc.id

  # HTTP access from anywhere
  ingress {
    from_port   = var.nginx_sg_ingress.from_port
    to_port     = var.nginx_sg_ingress.to_port
    protocol    = var.nginx_sg_ingress.protocol
    cidr_blocks = var.nginx_sg_ingress.cidr_blocks
  }

  # outbound internet access
  egress {
    from_port   = var.nginx_sg_egress.from_port
    to_port     = var.nginx_sg_egress.to_port
    protocol    = var.nginx_sg_egress.protocol
    cidr_blocks = var.nginx_sg_egress.cidr_blocks
  }

  tags = local.common_tags
}

# INSTANCES #
resource "aws_instance" "nginx1" {
  ami                    = nonsensitive(data.aws_ssm_parameter.ami.value)
  instance_type          = var.nginx1_instance_type
  subnet_id              = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.nginx-sg.id]
  user_data              = <<EOF
#! /bin/bash
sudo amazon-linux-extras install -y nginx1
sudo service nginx start
sudo rm /usr/share/nginx/html/index.html
echo '<html><head><title>Taco Team Server</title></head><body><h1>Welcome to the Taco Team Server</h1></body></html>' | sudo tee /usr/share/nginx/html/index.html
EOF

  tags = local.common_tags
}
