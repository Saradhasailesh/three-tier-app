output "vpc_id" {
  value = aws_vpc.demo_vpc.id
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet[*].id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet[*].id
}

output "allow_http" {
  value = aws_security_group.allow_http.id
}

output "allow_http_ssh" {
  value = aws_security_group.allow_http_ssh.id
}

output "allow_ssh" {
  value = aws_security_group.allow_ssh.id
}