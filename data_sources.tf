
# Data source to fetch the latest Red Hat AMI
data "aws_ami" "redhat" {
  most_recent = true
  owners      = ["309956199498"] # AWS Red Hat official account ID

  filter {
    name   = "name"
    values = ["RHEL-8.*GA*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
