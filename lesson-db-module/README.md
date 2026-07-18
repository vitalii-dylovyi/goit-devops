# lesson-db-module — Universal Terraform RDS / Aurora module

A production-ready, reusable Terraform module (`modules/rds`) that provisions **either** a
standard Amazon RDS instance **or** an Amazon Aurora cluster from the same code, controlled
by a single flag: `use_aurora`.

In both modes the module also creates the supporting resources:

- **DB Subnet Group** (`aws_db_subnet_group`) — picks public or private subnets based on `publicly_accessible`
- **Security Group** (`aws_security_group`) — opens the database port to the allowed CIDR ranges
- **Parameter Group** — `aws_db_parameter_group` for RDS, or `aws_rds_cluster_parameter_group` for Aurora

## Usage

```hcl
module "rds" {
  source = "./modules/rds"

  name       = "myapp-db"
  use_aurora = false          # false → standard RDS, true → Aurora cluster

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
  subnet_public_ids   = module.vpc.public_subnet_ids
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
```

## Input variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `name` | string | — | Name/identifier prefix for the instance or cluster |
| `use_aurora` | bool | `false` | `true` → Aurora cluster, `false` → standard RDS instance |
| `db_name` | string | — | Default database created inside the engine |
| `username` | string | — | Master username |
| `password` | string (sensitive) | — | Master password |
| `instance_class` | string | `db.t3.micro` | Instance size (e.g. `db.t3.medium`, `db.r6g.large`) |
| `multi_az` | bool | `false` | Multi-AZ standby replica (standard RDS) |
| `backup_retention_period` | number | `7` | Days of automated backups (`0` disables) |
| `parameters` | map(string) | `max_connections=200`, `log_min_duration_statement=500` | Engine parameters applied via the parameter group |
| `engine` | string | `postgres` | Engine for standard RDS (`postgres`, `mysql`, …) |
| `engine_version` | string | `17.2` | Version for standard RDS |
| `allocated_storage` | number | `20` | Disk size in GB (standard RDS only) |
| `parameter_group_family_rds` | string | `postgres17` | Parameter group family for standard RDS |
| `engine_cluster` | string | `aurora-postgresql` | Aurora engine (`aurora-postgresql`, `aurora-mysql`) |
| `engine_version_cluster` | string | `15.3` | Aurora engine version |
| `parameter_group_family_aurora` | string | `aurora-postgresql15` | Parameter group family for Aurora |
| `aurora_replica_count` | number | `1` | Number of Aurora read replicas (besides the writer) |
| `vpc_id` | string | — | VPC to deploy into |
| `subnet_private_ids` | list(string) | — | Private subnets (used when `publicly_accessible = false`) |
| `subnet_public_ids` | list(string) | — | Public subnets (used when `publicly_accessible = true`) |
| `publicly_accessible` | bool | `false` | Expose the DB to the internet |
| `db_port` | number | `5432` | Port opened in the security group (`3306` for MySQL) |
| `allowed_cidr_blocks` | list(string) | `["0.0.0.0/0"]` | CIDRs allowed to connect (restrict in production) |
| `tags` | map(string) | `{}` | Tags applied to all resources |

## Outputs

| Output | Description |
|--------|-------------|
| `endpoint` | Connection endpoint (RDS address or Aurora cluster endpoint) |
| `reader_endpoint` | Aurora reader endpoint (`null` for standard RDS) |
| `port` | Database port |
| `security_group_id` | ID of the created security group |
| `db_subnet_group_name` | Name of the created DB subnet group |

## How to change the database configuration

**Switch between RDS and Aurora** — flip a single flag:

```hcl
use_aurora = true   # Aurora cluster (writer + aurora_replica_count readers)
use_aurora = false  # single standard RDS instance
```

**Change the engine / version (standard RDS):**

```hcl
engine                     = "mysql"
engine_version             = "8.0"
parameter_group_family_rds = "mysql8.0"
db_port                    = 3306
```

**Change the engine / version (Aurora):**

```hcl
engine_cluster                = "aurora-mysql"
engine_version_cluster        = "8.0.mysql_aurora.3.05.2"
parameter_group_family_aurora = "aurora-mysql8.0"
```

**Change the instance size / storage:**

```hcl
instance_class    = "db.r6g.large"
allocated_storage = 100
```

The `engine_version` must match its `parameter_group_family_*` (e.g. PostgreSQL `17.x` → `postgres17`,
Aurora PostgreSQL `15.x` → `aurora-postgresql15`).

## Apply / destroy

```bash
terraform init
terraform apply
# ...verify the database in the AWS console...
terraform destroy
```

> **Warning:** managed databases incur cost. Run `terraform destroy` after review.
> `destroy` also removes the S3 bucket and DynamoDB table used for remote state — mind the teardown order.
