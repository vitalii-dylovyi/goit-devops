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
  vpc_name           = "lesson-7-vpc"
}

# ECR repository for the Django Docker image
module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = var.ecr_name
  scan_on_push = true
}

# EKS cluster deployed into the public subnets of the VPC above
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
