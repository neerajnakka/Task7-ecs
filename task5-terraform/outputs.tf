output "ec2_public_ip" {
  description = "Public IP of the Strapi Server"
  value       = aws_instance.app_server.public_ip
}

output "strapi_url" {
  description = "URL to access Strapi"
  value       = "http://${aws_instance.app_server.public_ip}:1337"
}
