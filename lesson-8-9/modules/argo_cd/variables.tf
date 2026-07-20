variable "name" {
  description = "Name of the Argo CD Helm release"
  type        = string
  default     = "argo-cd"
}

variable "namespace" {
  description = "Kubernetes namespace for Argo CD"
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "Version of the Argo CD Helm chart"
  type        = string
  default     = "5.46.4"
}

variable "github_username" {
  description = "GitHub username for the private repository credential"
  type        = string
  default     = ""
}

variable "github_pat" {
  description = "GitHub Personal Access Token (injected at apply time, not committed)"
  type        = string
  sensitive   = true
  default     = ""
}
