variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "ID of the existing VPC"
  type        = string
  default     = "vpc-06f2f42cee386037b"
}

variable "subnet_id" {
  description = "ID of the existing subnet"
  type        = string
  default     = "subnet-06427a94f9885658e"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "key_pair_name" {
  description = "Name of the existing key pair for RDP access"
  type        = string
  default     = "saastest"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket containing the ModelizeIT Analyzer"
  type        = string
  #default     = "ankeambomalaisahmbom2024 sas-sandbox-staging"
}

variable "application_port" {
  description = "Port on which the application runs"
  type        = number
  default     = 8883
}

variable "endpoint" {
  description = "This is the email where the cpuutilisation allerts will be sent to"
  default     = "string"
}

variable "destination_directory" {
  description = "EC2 instance distanation where Gatherer will be installed"
  type        = string
  default     = "C:\\ModelizeIT"
}

variable "s3_object_key" {
  description = "Key of the ModelizeIT Gatherer zip file in the S3 bucket"
  type        = string
}