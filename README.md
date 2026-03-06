# 🏗️ treinai-infra

Terraform infrastructure-as-code for the **treinAI** platform.

## Architecture

- **Resource Group:** `rg-treinai-{env}`
- **Managed Identity:** `treinai-identity-{env}` (User-Assigned, shared by all Functions)
- **Cosmos DB Serverless:** 9 containers, partition key `/tenantId`
- **Azure Functions:** 7 microservices (.NET 8 isolated, Consumption plan)
- **Static Web App:** React + Vite SPA
- **Key Vault:** Secrets residuais (main auth via Managed Identity)
- **Application Insights:** Logs, metrics, traces
- **RBAC:** Cosmos DB Data Contributor, Key Vault Secrets User, Monitoring Metrics Publisher

## Prerequisites

- [Terraform >= 1.7](https://www.terraform.io/downloads)
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
- Logged in: `az login`
- Correct subscription: `az account set --subscription "247f1805-23e4-49df-8359-ce71728346a3"`

## Remote State

State is stored in:
- **Storage Account:** `sttreinaitfstate`
- **Container:** `tfstate`
- **Resource Group:** `rg-treinai-tfstate`

## Usage

```bash
# Initialize
terraform init

# Plan (dev)
terraform plan -var-file="environments/dev.tfvars"

# Apply (dev)
terraform apply -var-file="environments/dev.tfvars"

# Destroy (dev)
terraform destroy -var-file="environments/dev.tfvars"
```

## Modules

| Module | Description |
|--------|-------------|
| `resource-group` | Resource Group |
| `managed-identity` | User-Assigned Managed Identity |
| `app-insights` | Application Insights + Log Analytics |
| `key-vault` | Azure Key Vault (RBAC enabled) |
| `cosmos-db` | Cosmos DB Serverless (9 containers) |
| `functions` | 7 Function Apps (Consumption) |
| `static-web-app` | Azure Static Web App (Free tier) |

## Naming Convention

`treinai-{resource}-{env}` — ex: `treinai-func-alunos-dev`
