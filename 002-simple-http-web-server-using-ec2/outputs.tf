output "access_url" {
  value = "http://${aws_instance.http_web_server.public_dns}"
}