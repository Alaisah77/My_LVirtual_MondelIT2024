# Generate an SSH key pair
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Upload public key to AWS
resource "aws_key_pair" "generated_key_pair" {
  key_name   = "redhat-instance-key" # Name of the key pair in AWS
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# Save the private key locally for secure SSH access
resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/redhat-instance-key.pem"
  file_permission = "0600"
}

  