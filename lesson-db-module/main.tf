terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# S3 bucket + DynamoDB table for Terraform remote state
module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = var.state_bucket_name
  table_name  = var.state_lock_table
}

# VPC with public and private subnets
module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  vpc_name           = "lesson-db-module-vpc"
}

# ECR repository
module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = var.ecr_name
  scan_on_push = true
}

# EKS cluster
module "eks" {
  source             = "./modules/eks"
  cluster_name       = var.cluster_name
  kubernetes_version = "1.30"
  subnet_ids         = module.vpc.private_subnet_ids
  instance_types     = ["t3.medium"]
  desired_size       = 2
  min_size           = 2
  max_size           = 4
}

# Universal database module.
# Toggle use_aurora to switch between a standard RDS instance and an Aurora cluster.
module "rds" {
  source = "./modules/rds"

  name       = "myapp-db"
  use_aurora = false

  # --- RDS-only ---
  engine                     = "postgres"
  engine_version             = "17.2"
  parameter_group_family_rds = "postgres17"

  # --- Aurora-only (used when use_aurora = true) ---
  engine_cluster                = "aurora-postgresql"
  engine_version_cluster        = "15.3"
  parameter_group_family_aurora = "aurora-postgresql15"
  aurora_replica_count          = 1

  # --- Common ---
  instance_class          = "db.t3.medium"
  allocated_storage       = 20
  db_name                 = "myapp"
  username                = "postgres"
  password                = var.db_password
  multi_az                = true
  backup_retention_period = 7

  vpc_id              = module.vpc.vpc_id
  subnet_private_ids  = module.vpc.private_subnet_ids
  subnet_public_ids   = module.vpc.private_subnet_ids
  publicly_accessible = true

  parameters = {
    max_connections            = "200"
    log_min_duration_statement = "500"
    work_mem                   = "8192"
  }

  tags = {
    Environment = "dev"
    Project     = "myapp"
  }
}
