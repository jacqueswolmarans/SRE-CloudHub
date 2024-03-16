terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  shared_config_files      = ["~/.aws/config"]
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "jacques-personal"
}

resource "aws_key_pair" "personal" {
  key_name   = "personal_key"
  public_key = file("~/.ssh/personal_key.pub")
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = "vpc-983523ff"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["222.155.56.130/32"] # Your public IP -> https://www.whatismyip.com/
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_instance" "app_server" {
  ami           = "ami-09c8d5d747253fb7a"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.personal.key_name

  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "SRE-CloudHub"
    IAC = "Terraform"
  }
}
