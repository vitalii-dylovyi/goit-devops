output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "db_endpoint" {
  description = "Database connection endpoint"
  value       = module.rds.endpoint
}

output "db_reader_endpoint" {
  description = "Aurora reader endpoint (null for standard RDS)"
  value       = module.rds.reader_endpoint
}

output "db_security_group_id" {
  description = "Security group ID of the database"
  value       = module.rds.security_group_id
}
