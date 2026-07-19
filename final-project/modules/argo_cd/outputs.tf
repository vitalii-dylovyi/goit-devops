output "argo_cd_server_service" {
  description = "In-cluster Argo CD server service DNS name"
  value       = "argo-cd-argocd-server.${var.namespace}.svc.cluster.local"
}

output "admin_password_cmd" {
  description = "Command to retrieve the initial Argo CD admin password"
  value       = "kubectl -n ${var.namespace} get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d"
}
