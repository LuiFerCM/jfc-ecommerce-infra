# Configuración CI/CD con GitHub Actions

## Arquitectura del Pipeline

```
Pull Request → terraform plan (comentario automático en PR)
Merge a main → terraform apply (despliegue automático)
Manual trigger → Build & Deploy Backend/Frontend
```

## Autenticación: GitHub OIDC → AWS

Se usa OpenID Connect (OIDC) en lugar de Access Keys para mayor seguridad.
GitHub Actions asume un IAM Role directamente, sin credenciales estáticas.

## Pasos de Configuración

### 1. Desplegar Infraestructura con CI/CD habilitado

En tu archivo `prod.tfvars`, configurar:

```hcl
enable_cicd         = true
github_org          = "tu-usuario-github"
github_repositories = ["backend-api", "frontend-app"]
```

### 2. Obtener el ARN del Role

Después del `terraform apply`:

```bash
terraform output github_actions_role_arn
# Output: arn:aws:iam::123456789012:role/jfc-ecommerce-prod-github-actions
```

### 3. Configurar Secrets en GitHub

En cada repositorio → Settings → Secrets → Actions:

| Secret | Valor |
|--------|-------|
| `AWS_ROLE_ARN` | ARN del output anterior |

### 4. Copiar Workflows

Copiar los archivos de `.github/workflows/` a tus repositorios:

- `deploy-backend.yml` → Repositorio del backend
- `deploy-frontend.yml` → Repositorio del frontend

### 5. Configurar Environments en GitHub

En Settings → Environments → crear `production` con:
- Required reviewers (opcional pero recomendado)
- Deployment branches: `main`

## Workflows Disponibles

| Workflow | Trigger | Función |
|----------|---------|---------|
| `terraform-plan.yml` | PR contra `main` | Plan + comentario en PR |
| `terraform-apply.yml` | Push a `main` | Apply automático |
| `deploy-backend.yml` | Manual | Build Docker + Deploy ECS |
| `deploy-frontend.yml` | Manual | Build + Sync S3 + Invalidar CF |

## Seguridad del Pipeline

- Sin Access Keys almacenadas (OIDC temporal)
- Roles con permisos mínimos (principio de menor privilegio)
- Condiciones en el IAM Role limitan a repos específicos
- Environment protection rules en GitHub
