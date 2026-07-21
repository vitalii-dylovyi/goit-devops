variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-west-2"
}

variable "state_bucket_name" {
  description = "Name of the S3 bucket for Terraform remote state"
  type        = string
  default     = "vitalii-tf-state-lesson-5"
}

variable "state_lock_table" {
  description = "Name of the DynamoDB table for state locking"
  type        = string
  default     = "terraform-locks"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnets" {
  description = "List of CIDR blocks for the private subnets"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones for the subnets"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "lesson-5-vpc"
}

variable "ecr_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "lesson-5-ecr"
}

variable "scan_on_push" {
  description = "Enable automatic image scanning on push to ECR"
  type        = bool
  default     = true
}
