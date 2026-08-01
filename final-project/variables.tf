variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-west-2"
}

variable "state_bucket_name" {
  description = "S3 bucket name for Terraform remote state"
  type        = string
  default     = "vitalii-tf-state-final-project"
}

variable "state_lock_table" {
  description = "DynamoDB table name for state locking"
  type        = string
  default     = "terraform-locks"
}

variable "ecr_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "final-project-ecr"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "final-project-eks"
}

variable "db_password" {
  description = "Master password for the RDS/Aurora database, supplied via TF_VAR_db_password (never committed)"
  type        = string
  sensitive   = true
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

variable "jenkins_admin_password" {
  description = "Jenkins admin password, supplied via TF_VAR_jenkins_admin_password (never committed)"
  type        = string
  sensitive   = true
}

variable "grafana_admin_password" {
  description = "Grafana admin password, supplied via TF_VAR_grafana_admin_password (never committed)"
  type        = string
  sensitive   = true
}

variable "django_secret_key" {
  description = "Django SECRET_KEY, supplied via TF_VAR_django_secret_key (never committed)"
  type        = string
  sensitive   = true
}
