variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-west-2"
}

variable "state_bucket_name" {
  description = "Name of the S3 bucket for Terraform remote state"
  type        = string
  default     = "vitalii-tf-state-lesson-8-9"
}

variable "state_lock_table" {
  description = "Name of the DynamoDB table for state locking"
  type        = string
  default     = "terraform-locks"
}

variable "ecr_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "lesson-8-9-ecr"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "lesson-8-9-eks"
}

variable "github_username" {
  description = "GitHub username for Jenkins/Argo CD repository credentials"
  type        = string
  default     = ""
}

variable "github_pat" {
  description = "GitHub Personal Access Token, supplied via TF_VAR_github_pat (never committed)"
  type        = string
  sensitive   = true
  default     = ""
}
