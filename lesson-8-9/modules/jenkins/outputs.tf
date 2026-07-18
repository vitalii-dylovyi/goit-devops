output "jenkins_release_name" {
  description = "Name of the Jenkins Helm release"
  value       = helm_release.jenkins.name
}

output "jenkins_namespace" {
  description = "Namespace where Jenkins is deployed"
  value       = helm_release.jenkins.namespace
}

output "jenkins_admin_password_cmd" {
  description = "Command to retrieve the Jenkins admin password"
  value       = "kubectl -n jenkins get secret jenkins -o jsonpath=\"{.data.jenkins-admin-password}\" | base64 -d"
}
