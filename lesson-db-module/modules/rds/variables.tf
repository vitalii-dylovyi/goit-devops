##############################
# General
##############################
variable "name" {
  description = "Name of the RDS instance or Aurora cluster (used as identifier prefix)"
  type        = string
}

variable "use_aurora" {
  description = "If true, create an Aurora cluster; if false, create a standard RDS instance"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to all created resources"
  type        = map(string)
  default     = {}
}

##############################
# Common DB settings
##############################
variable "db_name" {
  description = "Name of the default database to create"
  type        = string
}

variable "username" {
  description = "Master username for the database"
  type        = string
}

variable "password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true
}

variable "instance_class" {
  description = "Instance class for the DB instance (e.g. db.t3.medium)"
  type        = string
  default     = "db.t3.micro"
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment (standby replica in another AZ) for standard RDS"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Number of days to retain automated backups (0 disables backups)"
  type        = number
  default     = 7
}

variable "parameters" {
  description = "Map of DB engine parameters applied via the parameter group"
  type        = map(string)
  default = {
    max_connections            = "200"
    log_min_duration_statement = "500"
  }
}

##############################
# Standard RDS-only settings
##############################
variable "engine" {
  description = "Engine for standard RDS (e.g. postgres, mysql)"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Engine version for standard RDS (e.g. 17.2)"
  type        = string
  default     = "17.2"
}

variable "allocated_storage" {
  description = "Allocated storage in GB (standard RDS only)"
  type        = number
  default     = 20
}

variable "parameter_group_family_rds" {
  description = "Parameter group family for standard RDS (e.g. postgres17)"
  type        = string
  default     = "postgres17"
}

##############################
# Aurora-only settings
##############################
variable "engine_cluster" {
  description = "Engine for the Aurora cluster (e.g. aurora-postgresql, aurora-mysql)"
  type        = string
  default     = "aurora-postgresql"
}

variable "engine_version_cluster" {
  description = "Engine version for the Aurora cluster (e.g. 15.3)"
  type        = string
  default     = "15.3"
}

variable "parameter_group_family_aurora" {
  description = "Parameter group family for Aurora (e.g. aurora-postgresql15)"
  type        = string
  default     = "aurora-postgresql15"
}

variable "aurora_replica_count" {
  description = "Number of Aurora read-only replicas (in addition to the writer)"
  type        = number
  default     = 1
}

##############################
# Network
##############################
variable "vpc_id" {
  description = "ID of the VPC where the database is deployed"
  type        = string
}

variable "subnet_private_ids" {
  description = "List of private subnet IDs (used when publicly_accessible = false)"
  type        = list(string)
}

variable "subnet_public_ids" {
  description = "List of public subnet IDs (used when publicly_accessible = true)"
  type        = list(string)
}

variable "publicly_accessible" {
  description = "Whether the database is reachable from the internet"
  type        = bool
  default     = false
}

variable "db_port" {
  description = "Database port to open in the security group (5432 for PostgreSQL, 3306 for MySQL)"
  type        = number
  default     = 5432
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to connect to the database"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
