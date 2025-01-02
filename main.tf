

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
    #mkdirsource_security_group_id = aws_security_group.alb_sg.id
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
  ami                    = data.aws_ami.redhat.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = aws_key_pair.generated_key_pair.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  #iam_instance_profile        = aws_ian_instance_profile.ec2_instance_profile.name
  associate_public_ip_address = true
  monitoring                  = true
  user_data                   = templatefile("${path.module}/template/setup.tftpl", {})
  tags = {
    #saas:cost_by_project = "cloud_migration"
    #saas:cost_by_team    =  "capgemini"
    Name = "WindowsModelizeITInstance"
  }
}

# Allocate an Elastic IP
resource "aws_eip" "elastic_ip" {
  instance = aws_instance.redhat_instance.id

}


resource "aws_cloudwatch_metric_alarm" "my_cpu_alarm" {
  alarm_name          = "HighCPUUtilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 600
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This alarm triggers if CPU utilization exceeds 80% for 5 minutes"
  dimensions = {
    InstanceId = aws_instance.redhat_instance.id
  }
  actions_enabled = true

  alarm_actions = [
    "arn:aws:sns:us-east-1:123456789012:my-sns-topic"
  ]
}

resource "aws_sns_topic" "alarm_topic" {
  name = "alarm-topic"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.alarm_topic.arn
  protocol  = "email"
  endpoint  = var.endpoint
}
