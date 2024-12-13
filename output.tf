# outputs.tf
output "instance_url" {
  value = "http://${aws_eip.elastic_ip.public_ip}:${var.application_port}"
}

