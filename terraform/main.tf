resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "Main VPC"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "Main IGW"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_security_group" "default_sg" {
  name        = "default-instance-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 81
    to_port     = 81
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow from anywhere, adjust as needed
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "default-instance-sg"
  }
}

resource "random_id" "key_suffix" {
  byte_length = 4
}

resource "tls_private_key" "auth_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "auth_key" {
  key_name   = "deployer-${random_id.key_suffix.hex}"
  public_key = tls_private_key.auth_key.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.auth_key.private_key_pem
  filename        = pathexpand("~/.ssh/auth.pem")
  file_permission = "0600"
}

resource "aws_instance" "instance" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.default_sg.id]
  key_name               = aws_key_pair.auth_key.key_name
  monitoring             = true

  tags = {
    Name = var.instance_name
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 8
  }
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory/hosts.ini"
  content  = <<-EOT
    # Ansible inventory generated from Terraform outputs
    # Generated on: ${timestamp()}
    [webservers]
    ec2_instance ansible_host=${aws_instance.instance.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/auth.pem ansible_ssh_common_args='-o StrictHostKeyChecking=no'
    
    [webservers:vars]
    instance_id=${aws_instance.instance.id}
    public_ip=${aws_instance.instance.public_ip}
    nginx_port_80=80
    nginx_port_81=81
    
    [all:vars]
    ansible_python_interpreter=/usr/bin/python3
  EOT
}