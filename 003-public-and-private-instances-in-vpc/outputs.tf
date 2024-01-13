output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnets" {
  value = [for item in aws_subnet.public_subnets : item.id]
}

output "private_subnets" {
  value = [for item in aws_subnet.private_subnets : item.id]
}

output "igw" {
  value = aws_internet_gateway.igw.id
}

output "natgw" {
  value = aws_nat_gateway.natgw.id
}

output "natgw-eip" {
  value = aws_eip.eip.public_ip
}

output "public_instance_ip" {
  value = aws_instance.public_instance.public_ip
}