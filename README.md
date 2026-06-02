# ☁️ infrastructure-as-code-terraform-aws

Infraestructura en AWS definida como código con **Terraform** y **CloudFormation**, desplegando una API en ECS Fargate con ALB, VPC propia y ECR.

> **Repo 2 de 3 — Portfolio DevOps/Cloud**
> Este repo provisiona la infraestructura base. La app que corre en ella está en [`tasks-api-spring-boot-docker`](https://github.com/JoshuaSMC/tasks-api-spring-boot-docker). El pipeline de deploy automatizado está en [`devops-pipeline-github-actions-grafana`](https://github.com/JoshuaSMC/devops-pipeline-github-actions-grafana).

---

## ⚙️ Tecnologías

| Capa | Tecnología |
|------|-----------|
| IaC principal | Terraform 1.6+ |
| IaC alternativo | AWS CloudFormation |
| Provider | AWS (~> 5.0) |
| Cómputo | ECS Fargate |
| Balanceo | Application Load Balancer |
| Red | VPC custom con subnets públicas |
| Registry | ECR (Amazon Elastic Container Registry) |
| Observabilidad | CloudWatch Logs |

---

## 🗺️ Narrativa del portfolio

| Repo | Qué muestra |
|------|------------|
| [1. tasks-api-spring-boot-docker](https://github.com/JoshuaSMC/tasks-api-spring-boot-docker) | App dockerizada, publicada en GHCR con CI/CD |
| **2. infrastructure-as-code-terraform-aws** ← estás acá | Infraestructura como código con Terraform y CloudFormation |
| [3. devops-pipeline-github-actions-grafana](https://github.com/JoshuaSMC/devops-pipeline-github-actions-grafana) | Pipeline CI/CD completo: deploy automático + monitoreo con Grafana |

---

## 🏗️ Arquitectura

```
                         Internet
                            │
                            ▼
                    ┌───────────────┐
                    │      ALB      │  :80
                    │  (público)    │
                    └───────┬───────┘
                            │
              ┌─────────────┴──────────────┐
              │           VPC              │
              │    10.0.0.0/16             │
              │                            │
              │  ┌──────────┐  ┌────────┐  │
              │  │ Subnet A │  │Subnet B│  │
              │  │us-east-1a│  │us-east │  │
              │  │          │  │  -1b   │  │
              │  │ ┌──────┐ │  │┌──────┐│  │
              │  │ │ ECS  │ │  ││ ECS  ││  │
              │  │ │Task  │ │  ││Task  ││  │
              │  │ │:8080 │ │  ││:8080 ││  │
              │  │ └──────┘ │  │└──────┘│  │
              │  └──────────┘  └────────┘  │
              └────────────────────────────┘
                            │
                            ▼
                    ┌───────────────┐
                    │      ECR      │
                    │  (imágenes)   │
                    └───────────────┘
```

---

## 📁 Estructura del proyecto

```
.
├── main.tf                    # Root: instancia los 3 módulos
├── variables.tf               # Variables globales
├── outputs.tf                 # Outputs: URL de la app, cluster, ECR
├── terraform.tfvars.example   # Template de variables (sin secrets)
├── modules/
│   ├── networking/            # VPC, subnets, IGW, route tables, SGs
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── registry/              # ECR + lifecycle policy
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── container/             # ECS cluster, task def, service, ALB
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── cloudformation/
    └── stack.yml              # Stack CloudFormation equivalente
```

---

## 🧩 Módulos

### `networking`
Crea la red base: VPC con DNS habilitado, Internet Gateway, dos subnets públicas en distintas AZs, tabla de rutas y dos security groups (uno para el ALB en puerto 80, otro para los tasks ECS en el puerto de la app).

### `registry`
Provisiona un repositorio ECR con tags inmutables (`IMMUTABLE` — un tag no puede sobreescribirse una vez pusheado), escaneo de vulnerabilidades activado en cada push, y una lifecycle policy que retiene las últimas 10 imágenes para controlar costos.

### `container`
Orquesta el runtime: IAM role de ejecución, CloudWatch Log Group (retención 7 días), ECS cluster, task definition Fargate con healthcheck integrado, ALB con listener HTTP y target group, y el ECS service con `health_check_grace_period_seconds = 60` para que el ALB no marque los tasks como unhealthy mientras Spring Boot termina de arrancar.

---

## 🚀 Uso con Terraform

### Requisitos previos

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.6
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) configurado con credenciales válidas
- Cuenta AWS con permisos para crear VPC, ECS, ECR, ALB e IAM roles

### Configuración

```bash
# 1. Clonar el repositorio
git clone https://github.com/JoshuaSMC/infrastructure-as-code-terraform-aws.git
cd infrastructure-as-code-terraform-aws

# 2. Crear el archivo de variables
cp terraform.tfvars.example terraform.tfvars
# Editar terraform.tfvars con tus valores
```

### Despliegue

```bash
# Inicializar providers y módulos
terraform init

# Ver qué recursos se van a crear (dry-run)
terraform plan

# Aplicar la infraestructura
terraform apply
```

> Al finalizar, el output `app_url` muestra la URL pública de la API.

### Destrucción

```bash
# Eliminar todos los recursos creados
terraform destroy
```

---

## ☁️ Alternativa: CloudFormation

El archivo `cloudformation/stack.yml` define la misma infraestructura. Para desplegarlo:

```bash
aws cloudformation deploy \
  --template-file cloudformation/stack.yml \
  --stack-name tasks-api-prod \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
      ContainerImage=ghcr.io/joshuasmc/tasks-api:latest \
      Environment=prod
```

Para ver los outputs del stack:

```bash
aws cloudformation describe-stacks \
  --stack-name tasks-api-prod \
  --query "Stacks[0].Outputs"
```

---

## 📤 Outputs

| Output | Descripción |
|--------|------------|
| `app_url` | URL pública de la aplicación |
| `alb_dns_name` | DNS del Application Load Balancer |
| `ecr_repository_url` | URL del repositorio ECR para push de imágenes |
| `ecs_cluster_name` | Nombre del cluster ECS |
| `ecs_service_name` | Nombre del servicio ECS |

---

## 🔒 Decisiones técnicas

- **Módulos separados por responsabilidad**: networking, registry y container son independientes y reutilizables
- **Fargate (serverless)**: sin gestión de EC2 instances, ideal para portfolio y bajo costo inicial
- **ALB con health check**: apunta a `/actuator/health` — mismo endpoint que usa el HEALTHCHECK del Dockerfile
- **`health_check_grace_period_seconds = 60`**: le da tiempo a Spring Boot para iniciar antes de que el ALB empiece a evaluar la salud del task
- **ECR con tags inmutables**: una imagen pusheada con un tag específico no puede sobreescribirse, garantizando trazabilidad
- **Lifecycle policy en ECR**: retiene las últimas 10 imágenes y borra las anteriores para controlar costos
- **Validación de CPU y memoria en Terraform**: valores inválidos fallan en `plan`, no en `apply`
- **CloudFormation alternativo**: demuestra conocimiento de ambas herramientas IaC nativas y no-nativas de AWS
- **`terraform.tfvars` ignorado en git**: las variables con valores reales (región, cuenta, etc.) no se commitean

---

## 👤 Autor

- [@JoshuaSMC](https://github.com/JoshuaSMC)

---

## 📄 Licencia

MIT
