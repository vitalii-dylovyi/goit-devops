variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the EKS OIDC provider (from eks module)"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL of the EKS OIDC provider (from eks module)"
  type        = string
}

variable "chart_version" {
  description = "Version of the Jenkins Helm chart"
  type        = string
  default     = "5.8.27"
}

variable "github_username" {
  description = "GitHub username for the github-token credential"
  type        = string
}

variable "github_pat" {
  description = "GitHub Personal Access Token (injected at apply time, not committed)"
  type        = string
  sensitive   = true
}
