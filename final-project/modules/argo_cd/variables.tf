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
  description = "GitHub username for the Argo CD repository credential (private repo)"
  type        = string
}

variable "github_pat" {
  description = "GitHub PAT for the Argo CD repository credential (injected, not committed)"
  type        = string
  sensitive   = true
}

variable "db_host" {
  description = "RDS endpoint injected into the django-app via Argo CD helm parameters"
  type        = string
}

variable "db_password" {
  description = "Database password injected into the django-app (not committed)"
  type        = string
  sensitive   = true
}

variable "django_secret_key" {
  description = "Django SECRET_KEY injected into the django-app (not committed)"
  type        = string
  sensitive   = true
}
