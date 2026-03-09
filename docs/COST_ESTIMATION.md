# Estimación de Costos - JFC E-Commerce Infrastructure

## Resumen Ejecutivo

**Costo mensual estimado: ~$420 USD** (producción, tráfico moderado)

> Estimación basada en AWS Pricing Calculator para la región us-east-1.
> El uso de Aurora Serverless v2 + Fargate permite pagar solo por lo consumido,
> reduciendo costos significativamente vs instancias fijas.

---

## Desglose por Servicio

| Servicio | Componente | Configuración | Costo Mensual (USD) |
|----------|-----------|---------------|:-------------------:|
| **Compute** | ECS Fargate (2 tasks) | 0.5 vCPU, 1GB RAM c/u | ~$58 |
| **Database** | Aurora Serverless v2 | 0.5-4 ACU (2 instancias) | ~$115 |
| **Networking** | NAT Gateway | 1 NAT + tráfico | ~$45 |
| **Networking** | ALB | 1 ALB + LCU | ~$28 |
| **Caching** | ElastiCache Redis | cache.t4g.micro (1 nodo) | ~$12 |
| **CDN** | CloudFront | 100 GB transferencia | ~$9 |
| **Storage** | S3 (Frontend + Logs) | ~50 GB total | ~$3 |
| **Security** | WAF | 5 reglas managed + requests | ~$46 |
| **Security** | KMS | 1 key + operaciones | ~$3 |
| **Security** | Secrets Manager | 2 secrets | ~$1 |
| **Monitoring** | CloudWatch | Alarms + Logs + Dashboard | ~$35 |
| **Monitoring** | Container Insights | Métricas ECS | ~$10 |
| **Audit** | CloudTrail | 1 trail multi-región | ~$2 |
| **Bastion** | EC2 t3.micro | On-demand | ~$8 |
| **ECR** | Container Registry | ~5 GB imágenes | ~$1 |
| **VPC Endpoints** | 4 Interface Endpoints | ECR, Logs, SM | ~$44 |
| | | **TOTAL ESTIMADO** | **~$420** |

---

## Comparativa de Costos vs Arquitectura Tradicional

| Concepto | Arquitectura Tradicional | Esta Solución | Ahorro |
|----------|:------------------------:|:-------------:|:------:|
| Compute | EC2 (2x t3.medium) = $60 | Fargate = $58 | **-3%** |
| Database | RDS db.t3.medium = $50 | Aurora Serverless = $115* | -130%** |
| Total estimado | ~$556 | ~$420 | **~24%** |

> *Aurora Serverless v2 es más costoso en baseline, pero escala automáticamente
> y se reduce a 0.5 ACU en periodos de bajo tráfico, generando ahorros reales.
> **El ahorro real viene de NO pagar por capacidad ociosa durante horas de bajo tráfico.

---

## Optimizaciones de Costo Implementadas

1. **Aurora Serverless v2**: Escala automáticamente entre 0.5 y 4 ACUs.
   En horarios de bajo tráfico (noches, madrugadas) el costo baja a ~$0.06/hr.

2. **NAT Gateway único**: En lugar de uno por AZ, se usa uno solo.
   Ahorro: ~$45/mes.

3. **VPC Endpoints (Gateway)**: El endpoint de S3 es gratuito y elimina
   el tráfico de ECR/S3 por NAT Gateway.

4. **Fargate Spot (opcional)**: Para staging, se puede usar Fargate Spot
   con hasta 70% de descuento.

5. **S3 Lifecycle Policies**: Logs pasan a S3-IA a los 30 días y Glacier
   a los 90 días, reduciendo costos de almacenamiento ~60%.

6. **CloudFront Caching**: Reduce solicitudes al origen, optimizando
   costos de transferencia y compute.

7. **ECS Auto Scaling**: Scale-in agresivo reduce tasks en horarios
   de bajo tráfico.

---

## Escenarios de Costos

| Escenario | Tasks Fargate | ACUs Aurora | Costo Estimado |
|-----------|:------------:|:-----------:|:--------------:|
| **Bajo tráfico** (noches) | 2 | 0.5 | ~$280/mes |
| **Tráfico normal** | 2-3 | 1-2 | ~$420/mes |
| **Picos de tráfico** | 5-10 | 3-4 | ~$700/mes |
| **Black Friday** | 10+ | 4+ | ~$1,200/mes |

---

## Recomendaciones para Reducción de Costos

1. **Reserved Instances**: Para producción estable, considerar Savings Plans
   de 1 año para Fargate (~20% ahorro).

2. **Eliminar VPC Endpoints Interface**: Si el costo de los endpoints ($44/mes)
   supera el ahorro en NAT, considerar removerlos.

3. **Staging sin WAF ni CloudTrail**: Ya configurado en staging.tfvars
   para ahorrar ~$48/mes.

4. **Monitoreo**: Ajustar retención de logs CloudWatch de 30 a 14 días
   si no se requiere más.

---

## Link a AWS Pricing Calculator

Para generar tu propia estimación personalizada:
https://calculator.aws/#/estimate?id=273e8e9cc5267f8cd6d9ecb3fe6b27ba513d17f9

Servicios a incluir: ECS Fargate, Aurora Serverless v2, ElastiCache,
ALB, NAT Gateway, CloudFront, S3, WAF, CloudWatch, Secrets Manager, KMS
