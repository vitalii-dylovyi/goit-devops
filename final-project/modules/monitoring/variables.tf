variable "namespace" {
  description = "Kubernetes namespace for the monitoring stack"
  type        = string
  default     = "monitoring"
}

variable "prometheus_chart_version" {
  description = "Version of the prometheus Helm chart"
  type        = string
  default     = "25.8.0"
}

variable "grafana_chart_version" {
  description = "Version of the grafana Helm chart"
  type        = string
  default     = "7.3.0"
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  default     = "admin123"
  sensitive   = true
}
