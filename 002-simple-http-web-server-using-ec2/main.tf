data "aws_ami" "amzn_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
}

resource "local_file" "private_key" {
  content  = tls_private_key.ssh_key.private_key_pem
  filename = "${var.key_pair_name}.pem"
}

resource "aws_key_pair" "ec2_key_pair" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "aws_security_group" "allow_ssh" {
  name        = "ssh-sg"
  description = "Allow SSH inbound traffic"

  ingress {
    description      = "SSH from public internet"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "ssh-sg"
    }
  )
}

resource "aws_security_group" "allow_http" {
  name        = "http-sg"
  description = "Allow HTTP inbound traffic"

  ingress {
    description      = "HTTP from public internet"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "http-sg"
    }
  )
}

resource "aws_instance" "http_web_server" {
  ami                         = data.aws_ami.amzn_linux.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.ec2_key_pair.key_name
  security_groups             = [aws_security_group.allow_http.name, aws_security_group.allow_ssh.name]
  associate_public_ip_address = true
  user_data                   = file("user-data.sh")
  tags = merge(
    local.common_tags,
    {
      Name = "web-server"
    }
  )
}