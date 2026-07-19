output "namespace" {
  description = "Monitoring namespace"
  value       = var.namespace
}

output "grafana_admin_password_cmd" {
  description = "Command to fetch the Grafana admin password"
  value       = "kubectl get secret -n ${var.namespace} grafana -o jsonpath=\"{.data.admin-password}\" | base64 --decode"
}

output "prometheus_server_url" {
  description = "In-cluster Prometheus server URL"
  value       = "http://prometheus-server.${var.namespace}.svc:80"
}
