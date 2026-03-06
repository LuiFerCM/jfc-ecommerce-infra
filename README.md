# JFC E-Commerce Infrastructure

Infraestructura production-grade en AWS para plataforma de e-commerce de tres capas (Frontend, Backend, Datos), implementada con Terraform siguiendo principios de AWS Well-Architected Framework.

## Arquitectura

```
                    ┌─────────────────────────────────────────────────┐
                    │                   INTERNET                       │
                    └──────────┬────────────────────┬─────────────────┘
                               │                    │
                    ┌──────────▼──────┐   ┌────────▼─────────┐
                    │   CloudFront    │   │    Route 53       │
                    │   (Frontend)    │   │    (DNS)          │
                    └──────────┬──────┘   └────────┬─────────┘
                               │                    │
                    ┌──────────▼──────┐   ┌────────▼─────────┐
                    │   S3 Bucket     │   │    AWS WAF        │
                    │   (SPA Assets)  │   │    (OWASP Rules)  │
                    └─────────────────┘   └────────┬─────────┘
                                                    │
                    ┌───────────────────────────────▼─────────────────┐
                    │              VPC (10.0.0.0/16)                   │
                    │  ┌─────────────────────────────────────────┐    │
                    │  │  Public Subnets                          │    │
                    │  │  ┌──────────┐  ┌───────┐  ┌─────────┐  │    │
                    │  │  │   ALB    │  │  NAT  │  │ Bastion │  │    │
                    │  │  └────┬─────┘  └───────┘  └─────────┘  │    │
                    │  └───────┼─────────────────────────────────┘    │
                    │  ┌───────▼─────────────────────────────────┐    │
                    │  │  App Subnets (Private)                   │    │
                    │  │  ┌──────────┐  ┌──────────┐             │    │
                    │  │  │  Fargate │  │  Fargate │  ← Auto    │    │
                    │  │  │  Task 1  │  │  Task 2  │   Scaling  │    │
                    │  │  └────┬─────┘  └────┬─────┘             │    │
                    │  └───────┼──────────────┼──────────────────┘    │
                    │  ┌───────▼──────────────▼──────────────────┐    │
                    │  │  Data Subnets (Isolated)                 │    │
                    │  │  ┌──────────────┐  ┌────────────────┐   │    │
                    │  │  │ Aurora Srv v2│  │ ElastiCache    │   │    │
                    │  │  │ PostgreSQL   │  │ Redis 7.1      │   │    │
                    │  │  └──────────────┘  └────────────────┘   │    │
                    │  └─────────────────────────────────────────┘    │
                    └─────────────────────────────────────────────────┘
```

## Componentes

- **Networking**: VPC con 3 capas de subnets (public, app, data) en 2 AZs + VPC Endpoints
- **Compute**: ECS Fargate con Auto Scaling (CPU, Memory, ALB Requests)
- **Database**: Aurora Serverless v2 PostgreSQL (escala automáticamente de 0.5 a 4 ACUs)
- **Caching**: ElastiCache Redis 7.1 para sesiones y cache
- **Frontend**: S3 + CloudFront CDN con OAC (Origin Access Control)
- **Security**: WAF (OWASP), KMS, Secrets Manager, CloudTrail, IMDSv2
- **Observability**: CloudWatch Alarms + Dashboard + Container Insights + SNS
- **CI/CD**: GitHub Actions con OIDC (sin access keys)
- **Cost Management**: AWS Budgets con alertas escalonadas

## Estructura del Proyecto

```
jfc-ecommerce-infra/
├── main.tf                     # Orquestación de módulos
├── variables.tf                # Variables del root module
├── outputs.tf                  # Outputs principales
├── config.tf                   # Provider y backend config
├── environments/
│   ├── prod.tfvars             # Variables de producción
│   ├── prod.tfbackend          # Backend config producción
│   ├── staging.tfvars          # Variables de staging
│   └── staging.tfbackend       # Backend config staging
├── modules/
│   ├── alb/                    # Application Load Balancer + TLS
│   ├── bastion/                # Bastion Host (EC2 + SSM)
│   ├── budgets/                # AWS Budgets
│   ├── cicd/                   # GitHub Actions OIDC
│   ├── cloudtrail/             # Audit logging
│   ├── cloudwatch/             # Alarms + Dashboard + SNS
│   ├── compute/                # ECS Fargate + ECR + Auto Scaling
│   ├── elasticache/            # Redis cluster
│   ├── frontend/               # S3 + CloudFront CDN
│   ├── kms/                    # Customer Managed Key
│   ├── logs-bucket/            # Centralized S3 logging
│   ├── rds/                    # Aurora Serverless v2
│   ├── secrets/                # Secrets Manager
│   ├── vpc/                    # VPC + Subnets + NAT + Endpoints
│   └── waf/                    # Web Application Firewall
├── .github/workflows/          # CI/CD pipelines
├── docs/                       # Documentación adicional
├── diagramas/                  # Diagramas de arquitectura
└── app-test/                   # Aplicación de prueba
```

## Prerrequisitos

1. **Terraform** >= 1.5 instalado
2. **AWS CLI** configurado con credenciales
3. **Cuenta AWS** con permisos de administrador
4. **S3 Bucket** para el state de Terraform (crearlo manualmente antes)
5. **Git** + cuenta GitHub (para CI/CD)

## Guía de Despliegue Paso a Paso

### Paso 1: Crear el bucket para Terraform State

```bash
# Crear bucket S3 para el state (una sola vez)
aws s3api create-bucket \
  --bucket jfc-ecommerce-terraform-state \
  --region us-east-1

# Habilitar versionado
aws s3api put-bucket-versioning \
  --bucket jfc-ecommerce-terraform-state \
  --versioning-configuration Status=Enabled

# Habilitar encriptación
aws s3api put-bucket-encryption \
  --bucket jfc-ecommerce-terraform-state \
  --server-side-encryption-configuration \
  '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"aws:kms"}}]}'
```

### Paso 2: Clonar el repositorio

```bash
git clone https://github.com/<tu-usuario>/jfc-ecommerce-infra.git
cd jfc-ecommerce-infra
```

### Paso 3: Configurar variables de entorno

Editar `environments/prod.tfvars` con tus valores:

```hcl
# Obligatorios
alarm_emails        = ["tu-email@example.com"]
budget_alert_emails = ["tu-email@example.com"]

# Opcionales (para dominio personalizado)
domain_name     = "tu-dominio.com"
route53_zone_id = "Z1234567890ABC"

# CI/CD (si usas GitHub Actions)
github_org          = "tu-usuario-github"
github_repositories = ["backend-api", "frontend-app"]
```

### Paso 4: Inicializar Terraform

```bash
terraform init -backend-config="environments/prod.tfbackend"
```

### Paso 5: Validar la configuración

```bash
terraform validate
terraform fmt -check -recursive
```

### Paso 6: Revisar el plan

```bash
terraform plan -var-file="environments/prod.tfvars"
```

### Paso 7: Desplegar la infraestructura

```bash
terraform apply -var-file="environments/prod.tfvars"
```

> El despliegue toma ~15-20 minutos (Aurora y CloudFront son los más lentos).

### Paso 8: Obtener outputs

```bash
terraform output

# Outputs importantes:
# alb_dns_name           = "jfc-ecommerce-prod-alb-123456.us-east-1.elb.amazonaws.com"
# frontend_url           = "d1234567890.cloudfront.net"
# ecr_repository_urls    = ["123456789012.dkr.ecr.us-east-1.amazonaws.com/jfc-ecommerce-prod-api"]
# github_actions_role_arn = "arn:aws:iam::123456789012:role/jfc-ecommerce-prod-github-actions"
```

### Paso 9: Desplegar la aplicación de prueba

```bash
# Login a ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin \
  $(terraform output -raw ecr_repository_urls | tr -d '[]" ')

# Construir y subir imagen
cd app-test/backend
docker build -t $(terraform output -raw ecr_repository_urls | tr -d '[]" '):latest .
docker push $(terraform output -raw ecr_repository_urls | tr -d '[]" '):latest

# Forzar nuevo deployment
aws ecs update-service \
  --cluster jfc-ecommerce-prod-cluster \
  --service jfc-ecommerce-prod-api \
  --force-new-deployment

# Esperar a que el servicio se estabilice
aws ecs wait services-stable \
  --cluster jfc-ecommerce-prod-cluster \
  --services jfc-ecommerce-prod-api
```

### Paso 10: Desplegar el frontend de prueba

```bash
aws s3 sync app-test/frontend/ s3://$(terraform output -raw frontend_bucket) --delete
```

### Paso 11: Verificar el despliegue

```bash
# Verificar API via ALB
curl http://$(terraform output -raw alb_dns_name)/health

# Verificar Frontend via CloudFront
curl https://$(terraform output -raw frontend_url)

# Verificar ECS tasks
aws ecs describe-services \
  --cluster jfc-ecommerce-prod-cluster \
  --services jfc-ecommerce-prod-api \
  --query 'services[0].{running: runningCount, desired: desiredCount, status: status}'
```

## Configurar CI/CD con GitHub Actions

Ver [docs/CICD_SETUP.md](docs/CICD_SETUP.md) para la guía completa.

Resumen rápido:
1. Obtener `github_actions_role_arn` del output
2. Agregar secret `AWS_ROLE_ARN` en GitHub
3. Copiar workflows a tus repositorios
4. Push a `main` dispara despliegue automático

## Estimación de Costos

Costo mensual estimado: **~$420 USD** (producción)

Ver [docs/COST_ESTIMATION.md](docs/COST_ESTIMATION.md) para el desglose completo.

## Principios de Arquitectura Aplicados

### AWS Well-Architected Framework

1. **Excelencia Operativa**: IaC con Terraform, CI/CD automatizado, CloudWatch Dashboard
2. **Seguridad**: KMS encryption at rest, WAF, Secrets Manager, VPC segmentation, CloudTrail, IMDSv2
3. **Fiabilidad**: Multi-AZ, Auto Scaling, Aurora Serverless auto-scaling, circuit breaker en ECS
4. **Eficiencia de Rendimiento**: Fargate (right-sizing), Redis caching, CloudFront CDN, Aurora Serverless v2
5. **Optimización de Costos**: Pay-per-use (Serverless v2 + Fargate), NAT único, S3 lifecycle, Budgets

### Mejoras sobre arquitectura de referencia

| Aspecto | Referencia (CesarLeiva) | Esta Solución |
|---------|------------------------|---------------|
| Database | RDS PostgreSQL (instancia fija) | **Aurora Serverless v2** (auto-scaling) |
| NAT Costs | NAT Gateway por AZ | **NAT único** + VPC Endpoints |
| Scaling | CPU + Memory | **CPU + Memory + ALB Requests** |
| Observability | Solo Alarms | **Alarms + Dashboard + Container Insights** |
| CI/CD Workflows | Templates básicos | **Plan en PR + Apply en merge + Deploy manual** |
| Environments | Solo QA | **Prod + Staging** con configs diferenciadas |
| Frontend OAC | OAI (legacy) | **OAC (recomendado por AWS)** |
| Log Format | Plain text | **Parquet** (más eficiente para queries) |

## Cleanup

```bash
# Destruir toda la infraestructura
terraform destroy -var-file="environments/prod.tfvars"

# No olvidar eliminar el bucket de state
aws s3 rb s3://jfc-ecommerce-terraform-state --force
```

> **Importante**: Verificar que `db_deletion_protection = false` antes del destroy.

## Soporte

Para dudas o issues, contactar al equipo de infraestructura.
