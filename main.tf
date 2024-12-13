

# Security Group to allow SSH and application port access
resource "aws_security_group" "instance_sg" {
  name        = "instance_sg"
  description = "Allow SSH and application port"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow ALB to connect to instance"
    from_port   = 8883
    to_port     = 8883
    protocol    = "tcp"
    source_security_group_id = aws_security_group.alb_sg.id
  }

  ingress {
    description = "SSH"
    from_port   = 8880
    to_port     = 8880
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Application Port"
    from_port   = var.application_port
    to_port     = var.application_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# IAM Role for EC2 to access S3
resource "aws_iam_role" "ec2_role" {
  name = "ec2_s3_access_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# IAM Policy for S3 access
resource "aws_iam_policy" "s3_access_policy" {
  name        = "s3_access_policy"
  description = "Policy to allow S3 access"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["s3:GetObject", "s3:ListBucket"]
      Resource = [
        "arn:aws:s3:::${var.s3_bucket_name}",
        "arn:aws:s3:::${var.s3_bucket_name}/*"
      ]
    }]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

# Create an instance profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_role.name
}


# EC2 Instance
resource "aws_instance" "redhat_instance" {
  ami                         = data.aws_ami.redhat.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  key_name                    = aws_key_pair.generated_key_pair.key_name
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name
  vpc_security_group_ids      = [aws_security_group.instance_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y aws-cli
              aws s3 cp s3://${var.s3_bucket_name}/modelizeit-analyzer.tar.gz /tmp/
              tar -xzf /tmp/modelizeit-analyzer.tar.gz -C /opt/
              /opt/modelizeit-analyzer/install.sh
              EOF

  tags = {
    Name = "SaaSInstance"
  }
}

# Allocate an Elastic IP
resource "aws_eip" "elastic_ip" {
  instance = aws_instance.redhat_instance.id

}

