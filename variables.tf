# ──────────────────────────────────────────────
# Variáveis Globais — treinAI Infrastructure
# ──────────────────────────────────────────────

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "brazilsouth"
}

variable "project" {
  description = "Project name used for naming convention"
  type        = string
  default     = "treinai"
}

variable "owner" {
  description = "Owner tag for all resources"
  type        = string
  default     = "tbongiovani"
}

variable "cosmos_db_containers" {
  description = "List of Cosmos DB containers to create"
  type = list(object({
    name               = string
    partition_key_path = string
  }))
  default = [
    { name = "usuarios", partition_key_path = "/tenantId" },
    { name = "treinos", partition_key_path = "/tenantId" },
    { name = "atividades", partition_key_path = "/tenantId" },
    { name = "avaliacoes", partition_key_path = "/tenantId" },
    { name = "alunos", partition_key_path = "/tenantId" },
    { name = "nutricao", partition_key_path = "/tenantId" },
    { name = "planos-nutricionais", partition_key_path = "/tenantId" },
    { name = "exercicios", partition_key_path = "/tenantId" },
    { name = "objetivos", partition_key_path = "/tenantId" },
    { name = "notificacoes", partition_key_path = "/tenantId" },
    { name = "historico-peso", partition_key_path = "/tenantId" },
    { name = "tenants", partition_key_path = "/id" },
  ]
}

variable "function_apps" {
  description = "List of Function App microservices to create"
  type        = list(string)
  default = [
    "alunos",
    "treinos",
    "atividades",
    "avaliacoes",
    "nutricao",
    "relatorios",
    "admin",
  ]
}

# ──────────────────────────────────────────────
# Azure AD B2C (E1-07)
# ──────────────────────────────────────────────

variable "b2c_tenant_name" {
  description = "B2C tenant domain prefix (e.g. treinaidev → treinaidev.onmicrosoft.com)"
  type        = string
  default     = "treinaidev"
}

variable "b2c_display_name" {
  description = "Display name for the B2C directory"
  type        = string
  default     = "treinAI Dev"
}
