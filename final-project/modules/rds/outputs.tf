output "endpoint" {
  description = "Connection endpoint of the database (RDS instance or Aurora cluster)"
  value       = var.use_aurora ? try(aws_rds_cluster.aurora[0].endpoint, null) : try(aws_db_instance.standard[0].address, null)
}

output "reader_endpoint" {
  description = "Reader endpoint (Aurora only; null for standard RDS)"
  value       = var.use_aurora ? try(aws_rds_cluster.aurora[0].reader_endpoint, null) : null
}

output "port" {
  description = "Database port"
  value       = var.db_port
}

output "security_group_id" {
  description = "ID of the security group attached to the database"
  value       = aws_security_group.rds.id
}

output "db_subnet_group_name" {
  description = "Name of the DB subnet group"
  value       = aws_db_subnet_group.default.name
}
