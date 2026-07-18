# Lesson 5 — Terraform AWS Infrastructure

Terraform configuration that provisions a base AWS infrastructure:

- **Remote state** in an S3 bucket with a DynamoDB table for state locking.
- **VPC** with 3 public and 3 private subnets, an Internet Gateway, and a NAT Gateway.
- **ECR** repository for storing Docker images with scan-on-push enabled.

## Project structure

```
lesson-5/
├── main.tf                  # Root module – wires the modules together and configures the provider
├── backend.tf               # S3 + DynamoDB backend configuration for remote state
├── outputs.tf               # Aggregated outputs from all modules
│
├── modules/
│   ├── s3-backend/          # S3 bucket + DynamoDB table for Terraform state
│   │   ├── s3.tf
│   │   ├── dynamodb.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── vpc/                 # VPC, subnets, IGW, NAT, route tables
│   │   ├── vpc.tf
│   │   ├── routes.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── ecr/                 # ECR repository
│       ├── ecr.tf
│       ├── variables.tf
│       └── outputs.tf
│
└── README.md
```

## Modules

### s3-backend
Creates the S3 bucket used to store Terraform state files with **versioning enabled**
(so state history is preserved) and **server-side encryption (AES256)**. Public access
to the bucket is fully blocked. A **DynamoDB table** (`terraform-locks`) with a `LockID`
hash key is created to lock the state and prevent concurrent `apply` runs.
Outputs: S3 bucket name/URL and DynamoDB table name.

### vpc
Creates a VPC from a CIDR block with:
- 3 public subnets (auto-assign public IP) and 3 private subnets, spread across 3 AZs.
- An Internet Gateway for the public subnets.
- A NAT Gateway (in the first public subnet, with an Elastic IP) so private subnets get outbound internet.
- Route tables: public subnets route `0.0.0.0/0` to the IGW; private subnets route `0.0.0.0/0` to the NAT Gateway.
Outputs: VPC ID, public/private subnet IDs, IGW ID, NAT Gateway ID.

### ecr
Creates an ECR repository with **scan-on-push** enabled, a **lifecycle policy** that keeps
only the last 10 images, and a **repository access policy** allowing image pulls.
Outputs: repository URL, ARN, and name.

## Usage

```bash
terraform init
terraform plan
terraform apply
terraform destroy
```

### First-run note (chicken-and-egg with the backend)

`backend.tf` points at the S3 bucket / DynamoDB table that the `s3-backend` module
creates. On a brand-new environment those don't exist yet, so bootstrap in two steps:

1. Comment out `backend.tf` (or run `terraform init -backend=false`) and `apply` once to
   create the S3 bucket and DynamoDB table.
2. Re-enable `backend.tf` and run `terraform init` again — Terraform will migrate the
   state into S3.

You also need AWS credentials configured (e.g. `aws configure` or environment variables)
before running `terraform apply`.
