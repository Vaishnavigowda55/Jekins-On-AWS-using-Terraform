terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.72.1"
    }
  }
}

provider "aws" {
  region = var.region

}
resource "aws_key_pair" "keypair" {
  key_name   = "demo.pem"
  public_key = file("${path.module}/demo.pub")
}


resource "aws_instance" "myserver" {
  ami           = "ami-0f88e80871fd81e91"
  instance_type = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.allow_http_ssh.id]
  associate_public_ip_address = true

  user_data = file("${path.module}/jen-install.sh")

  tags = {
    Name = "Jenkins with terraform"
  }
}
resource "aws_security_group" "allow_http_ssh" {
  name        = "allow_http_ssh"
  description = "Allow HTTP and SSH traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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
