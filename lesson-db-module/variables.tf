variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-west-2"
}

variable "state_bucket_name" {
  description = "Name of the S3 bucket for Terraform remote state"
  type        = string
  default     = "vitalii-tf-state-lesson-db-module"
}

variable "state_lock_table" {
  description = "Name of the DynamoDB table for state locking"
  type        = string
  default     = "terraform-locks"
}

variable "ecr_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "lesson-db-module-ecr"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "lesson-db-module-eks"
}

variable "db_password" {
  description = "Master password for the RDS/Aurora database"
  type        = string
  sensitive   = true
  default     = "admin123AWS23"
}
