output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "ecr_repository_url" {
  description = "URL of the ECR repository for the Django image"
  value       = module.ecr.repository_url
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint of the EKS cluster API server"
  value       = module.eks.cluster_endpoint
}

output "jenkins_namespace" {
  description = "Namespace where Jenkins is deployed"
  value       = module.jenkins.jenkins_namespace
}

output "jenkins_admin_password_cmd" {
  description = "Command to fetch the Jenkins admin password"
  value       = module.jenkins.jenkins_admin_password_cmd
}

output "argo_cd_admin_password_cmd" {
  description = "Command to fetch the Argo CD initial admin password"
  value       = module.argo_cd.admin_password_cmd
}
