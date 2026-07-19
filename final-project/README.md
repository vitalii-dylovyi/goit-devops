# DevOps CI/CD — Final Project

Full DevOps infrastructure on AWS, provisioned end-to-end with **Terraform**: a Kubernetes
cluster running a complete **CI/CD pipeline** (Jenkins → ECR → Argo CD/GitOps), a managed
**database**, and a **Prometheus + Grafana** monitoring stack — deployed with a single
`terraform apply`.

## Architecture

```
                              ┌──────────────────────────── AWS ────────────────────────────┐
                              │                                                              │
   Developer ──push──▶ GitHub │   VPC (public + private subnets, IGW, NAT, route tables)     │
                        │     │     │                                                        │
                        │     │     ├─ ECR ............ Docker image registry                │
                        │     │     ├─ RDS / Aurora ... PostgreSQL (private subnets)         │
                        │     │     └─ EKS (Kubernetes) ─────────────────────────────────┐   │
                        │     │           │  namespace: jenkins   → Jenkins (Kaniko CI)  │   │
                        └─────┼──────────▶│  namespace: argocd    → Argo CD  (GitOps CD) │   │
                              │           │  namespace: monitoring→ Prometheus + Grafana │   │
                              │           │  namespace: default   → django-app (Helm)    │   │
                              │           └──────────────────────────────────────────────┘   │
                              └──────────────────────────────────────────────────────────────┘
```

**CI/CD flow:** a push triggers the Jenkins pipeline (`Django/Jenkinsfile`) → Kaniko builds the
image and pushes it to **ECR** → the pipeline bumps the image tag in
`charts/django-app/values.yaml` and pushes to Git → **Argo CD** detects the change and syncs the
`django-app` Helm release into the cluster.

## Repository structure

```
final-project/
├── main.tf              # wires all modules together
├── backend.tf           # S3 + DynamoDB remote state
├── variables.tf
├── outputs.tf
├── modules/
│   ├── s3-backend/      # S3 bucket + DynamoDB lock table
│   ├── vpc/             # VPC, public/private subnets, IGW, NAT, routes
│   ├── ecr/             # ECR repository
│   ├── eks/             # EKS cluster + OIDC + EBS CSI driver
│   ├── rds/             # RDS instance OR Aurora cluster (use_aurora)
│   ├── jenkins/         # Jenkins via Helm + jenkins-sa IRSA role (ECR push)
│   ├── argo_cd/         # Argo CD via Helm + Applications/Repositories subchart
│   └── monitoring/      # Prometheus + Grafana via Helm
├── charts/
│   └── django-app/      # Helm chart (deployment, service, configmap, hpa, ingress)
└── Django/              # application source
    ├── app/
    ├── study_project/
    ├── Dockerfile
    ├── Jenkinsfile      # CI/CD pipeline
    └── docker-compose.yaml
```

## Security

- **VPC** isolation with dedicated public/private subnets; the database uses **private subnets**
  (`publicly_accessible = false`) and a Security Group scoped to the DB port.
- **IAM via IRSA**: the `jenkins-sa` service account assumes an IAM role (OIDC federation) with
  a least-privilege policy limited to the ECR actions needed to push images. The EBS CSI driver
  likewise uses a dedicated IRSA role.
- **Secrets** (GitHub PAT, DB and admin passwords) are provided via variables / Jenkins
  credentials and are **not** committed — placeholders (`<ACCOUNT_ID>`,
  `<YOUR_GITHUB_USERNAME>`, `<YOUR_GITHUB_PAT>`) must be filled in before applying.

## Prerequisites

- AWS account + credentials configured (`aws configure`)
- `terraform >= 1.0`, `kubectl`, `helm`
- Before applying, set:
  - `<ACCOUNT_ID>` in `Django/Jenkinsfile` → your AWS account ID
  - `<YOUR_GITHUB_USERNAME>` / `<YOUR_GITHUB_PAT>` in `modules/jenkins/values.yaml` and
    `modules/argo_cd/charts/values.yaml`

## 1. Deploy

```bash
terraform init
terraform plan
terraform apply
```

Point `kubectl` at the new cluster:

```bash
aws eks update-kubeconfig --name final-project-eks --region us-west-2
```

## 2. Verify resources

```bash
kubectl get all -n jenkins
kubectl get all -n argocd
kubectl get all -n monitoring
```

## 3. Access the services (port-forward)

```bash
# Jenkins
kubectl port-forward svc/jenkins 8080:8080 -n jenkins
# Argo CD
kubectl port-forward svc/argocd-server 8081:443 -n argocd
# Grafana
kubectl port-forward svc/grafana 3000:80 -n monitoring
```

Retrieve admin passwords (also printed as Terraform outputs):

```bash
kubectl -n jenkins get secret jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 -d
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
kubectl -n monitoring get secret grafana -o jsonpath="{.data.admin-password}" | base64 --decode
```

## 4. Demonstrate CI/CD

1. Trigger the Jenkins job `goit-django-docker` (or push to the repo).
2. Watch Kaniko build and push the image to ECR, then commit the new tag to
   `charts/django-app/values.yaml`.
3. In the Argo CD UI, the `django-app` Application picks up the change and syncs it — the new
   Pods roll out automatically.

## 5. Monitoring & autoscaling

- Open Grafana, confirm the **Prometheus** data source is connected
  (`http://prometheus-server.monitoring.svc:80`), and import a Kubernetes dashboard (e.g. ID
  `315` or `1860`) to view cluster/pod metrics.
- The `django-app` chart ships a **HorizontalPodAutoscaler** (`templates/hpa.yaml`) that scales
  Pods based on CPU utilisation.

## Switching RDS ↔ Aurora

The `rds` module is universal — flip one flag in `main.tf`:

```hcl
module "rds" {
  use_aurora = true   # Aurora cluster (writer + readers) instead of a single RDS instance
}
```

## Teardown

> **Warning:** managed cloud resources incur cost. Always tear down after review.

```bash
terraform destroy
```

`destroy` also removes the S3 state bucket and DynamoDB lock table — mind the teardown order and
back up any state you need first.
