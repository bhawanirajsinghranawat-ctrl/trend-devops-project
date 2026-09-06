variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "aws_availability_zone" {
  description = "AWS availability zone"
  type        = string
  default     = "ap-south-1a"
}

variable "ami_id" {
  description = "AMI ID for Jenkins EC2"
  type        = string
}
