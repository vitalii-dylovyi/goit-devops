# Тема 7 — Вивчення Helm (Kubernetes + ECR + Helm)

Домашнє завдання: підняти кластер **Amazon EKS** через Terraform у вже наявній
мережі (VPC), налаштувати **ECR** для Docker-образу Django-застосунку та розгорнути
застосунок у кластері за допомогою власного **Helm-чарта** (Deployment, Service,
ConfigMap, HPA).

## Структура проєкту

```
lesson-7/
├── main.tf              # Підключення модулів (s3-backend, vpc, ecr, eks)
├── variables.tf         # Кореневі змінні (регіон, імена ресурсів)
├── backend.tf           # Remote state: S3 + DynamoDB
├── outputs.tf           # Загальні виводи (VPC, ECR URL, EKS endpoint)
│
├── modules/
│   ├── s3-backend/      # S3-бакет + DynamoDB для стейтів
│   ├── vpc/             # VPC, публічні/приватні підмережі, IGW, NAT, маршрути
│   ├── ecr/             # ECR-репозиторій + lifecycle/pull-політики
│   └── eks/             # EKS-кластер + IAM-ролі + managed node group
│
└── charts/
    └── django-app/
        ├── Chart.yaml
        ├── values.yaml           # Образ, сервіс, ресурси, autoscaler, ConfigMap
        └── templates/
            ├── deployment.yaml   # Django з образом з ECR, envFrom ConfigMap
            ├── service.yaml      # LoadBalancer (зовнішній доступ)
            ├── configmap.yaml    # Змінні середовища (перенесені з теми 4)
            ├── hpa.yaml          # Масштабування 2→6 подів при CPU > 70%
            └── ingress.yaml      # (Бонус) Ingress + TLS через cert-manager
```

## Передумови

- AWS-акаунт та налаштований `aws cli` (`aws configure`)
- `terraform >= 1.0`, `kubectl`, `helm`, `docker`

## Крок 1. Terraform: VPC, ECR та EKS

```bash
cd lesson-7

# Перший запуск — тимчасово закоментуйте backend.tf, щоб створити бакет стейтів,
# або створіть бакет/таблицю заздалегідь. Далі:
terraform init
terraform plan
terraform apply
```

Після `apply` збережіть виводи:

```bash
terraform output ecr_repository_url
terraform output eks_cluster_name
```

## Крок 2. Доступ до кластера через kubectl

```bash
aws eks update-kubeconfig --region us-west-2 --name $(terraform output -raw eks_cluster_name)
kubectl get nodes
```

## Крок 3. Збірка й завантаження Docker-образу в ECR

Django-код (тема 4) знаходиться в гілці `lesson-4`. З директорії з `Dockerfile`:

```bash
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=us-west-2
REPO=lesson-7-ecr

aws ecr get-login-password --region $REGION \
  | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

docker build -t $REPO .
docker tag $REPO:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO:latest
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO:latest
```

## Крок 4. Metrics Server (потрібен для роботи HPA)

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

## Крок 5. Розгортання Helm-чарта

У `charts/django-app/values.yaml` вкажіть `image.repository` (URL з ECR):

```bash
helm upgrade --install my-django charts/django-app \
  --set image.repository=$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO \
  --set image.tag=latest
```

Перевірка:

```bash
kubectl get pods
kubectl get svc my-django-django      # EXTERNAL-IP LoadBalancer'а
kubectl get configmap my-django-config
kubectl get hpa                        # має показувати цілі 2..6, target 70%
```

Застосунок буде доступний за `EXTERNAL-IP` сервісу на порту 80.

## Компоненти Helm-чарта

| Ресурс      | Файл                       | Призначення |
|-------------|----------------------------|-------------|
| Deployment  | `templates/deployment.yaml` | Запуск Django з образу ECR, змінні через `envFrom` → ConfigMap, resource requests для HPA |
| Service     | `templates/service.yaml`    | `LoadBalancer`, зовнішній доступ, порт 80 → 8000 |
| ConfigMap   | `templates/configmap.yaml`  | Змінні середовища з теми 4 (`POSTGRES_*`, `DJANGO_SETTINGS_MODULE`) |
| HPA         | `templates/hpa.yaml`        | `autoscaling/v2`, 2→6 подів при CPU > 70% |
| Ingress     | `templates/ingress.yaml`    | (Бонус) вмикається через `ingress.enabled=true`, TLS через cert-manager |

## Бонус: Ingress + TLS

```bash
helm upgrade --install my-django charts/django-app \
  --set ingress.enabled=true \
  --set ingress.host=yourdomain.com \
  --set ingress.tls=true
```
Потребує встановленого ingress-nginx та cert-manager у кластері.

## Прибирання ресурсів (щоб не платити)

```bash
helm uninstall my-django
terraform destroy
```

## Формат оцінювання (для довідки)

- Модуль `eks` — 30 балів
- Модуль `ecr` — 20 балів
- Helm-чарт (Deployment, Service, ConfigMap, HPA) — 40 балів
- README.md — 10 балів
