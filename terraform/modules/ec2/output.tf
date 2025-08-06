output "app_server_ids" {
  value = aws_instance.app_server[*].id
}
