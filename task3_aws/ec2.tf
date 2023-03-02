provider "aws" {
  access_key = "" # Your akey
  secret_key = "" # Your skey  
  region     = "us-east-1"
}

resource "aws_instance" "Moodle_server" {
  ami                    = var.ami
  instance_type          = "t2.small"
  vpc_security_group_ids = [aws_security_group.moodle_sg.id]
  key_name               = aws_key_pair.tfkey1.key_name
  user_data              = file("hometask.sh")

  root_block_device {
    volume_size = "10"
    volume_type = "gp2"
  }
  tags = var.tags
}

resource "aws_key_pair" "tfkey1" {
  key_name   = "tfkey1"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "TF-key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "tfkey"
}

resource "aws_security_group" "moodle_sg" {
  name        = "MoodleSC"
  description = "MoodleSC Terraform"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "instance_public_ip" {
  description = "Public_IP_EC2"
  value       = aws_instance.Moodle_server.public_ip
}