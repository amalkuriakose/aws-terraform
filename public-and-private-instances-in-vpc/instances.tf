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

resource "aws_instance" "public_instance" {
  ami                         = data.aws_ami.amzn_linux.id
  instance_type               = var.instance_type
  availability_zone           = aws_subnet.public_subnets[local.azs_list[0]].availability_zone
  key_name                    = aws_key_pair.ec2_key_pair.key_name
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id, aws_security_group.allow_http.id]
  subnet_id                   = aws_subnet.public_subnets[local.azs_list[0]].id
  associate_public_ip_address = true
  user_data                   = file("user-data-public.sh")
  tags = merge(
    local.common_tags,
    {
      Name = "public-instance"
    }
  )
}

resource "aws_instance" "private_instance" {
  ami                    = data.aws_ami.amzn_linux.id
  instance_type          = var.instance_type
  availability_zone      = aws_subnet.private_subnets[local.azs_list[0]].availability_zone
  key_name               = aws_key_pair.ec2_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id, aws_security_group.allow_http.id]
  subnet_id              = aws_subnet.private_subnets[local.azs_list[0]].id
  user_data              = file("user-data-private.sh")
  tags = merge(
    local.common_tags,
    {
      Name = "private-instance"
    }
  )
}