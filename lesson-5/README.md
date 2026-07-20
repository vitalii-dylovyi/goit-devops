# Lesson 5 — IaC with Terraform (AWS)

Terraform project that provisions the base AWS infrastructure using reusable modules and a
remote state backend.

## Components

- **s3-backend** — S3 bucket + DynamoDB table for Terraform remote state and state locking.
- **vpc** — VPC with public and private subnets across 3 AZs, Internet Gateway, NAT Gateway and
  route tables.
- **ecr** — Elastic Container Registry repository (image scan on push, lifecycle policy keeping
  the last 10 images). The repository policy allows pull **only from this AWS account** (private).

## Repository structure

```
lesson-5/
├── main.tf              # module wiring
├── backend.tf           # S3 + DynamoDB remote state
├── outputs.tf
└── modules/
    ├── s3-backend/      # s3.tf, dynamodb.tf, variables.tf, outputs.tf
    ├── vpc/             # vpc.tf, routes.tf, variables.tf, outputs.tf
    └── ecr/             # ecr.tf, variables.tf, outputs.tf
```

## Prerequisites

- AWS account and credentials (`aws configure`)
- `terraform >= 1.0`

## Usage

```bash
terraform init      # initialise providers and the S3 backend
terraform plan      # review the planned changes
terraform apply     # create the infrastructure
```

Key outputs:

- `vpc_id` — ID of the created VPC
- `ecr_repository_url` — URL used to tag/push images

## Notes on security

- The ECR repository policy restricts pull to `arn:aws:iam::<account-id>:root`, so images are
  **not** publicly readable.
- Remote state is stored encrypted in S3 with DynamoDB-based locking to prevent concurrent
  applies.

## Teardown

> Managed cloud resources incur cost — destroy them after review.

```bash
terraform destroy
```

`destroy` also removes the S3 state bucket and DynamoDB lock table, so mind the teardown order.
