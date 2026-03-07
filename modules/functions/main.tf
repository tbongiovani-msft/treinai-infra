# ──────────────────────────────────────────────
# Module: Azure Functions (Consumption Plan)
# Creates: Storage Account + Service Plan + Function App per microservice
# ──────────────────────────────────────────────

variable "function_apps" {
  description = "List of function app domain names (e.g., alunos, treinos)"
  type        = list(string)
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "managed_identity_id" {
  description = "User-Assigned Managed Identity resource ID"
  type        = string
}

variable "managed_identity_client_id" {
  description = "User-Assigned Managed Identity client ID"
  type        = string
}

variable "app_insights_connection_string" {
  description = "Application Insights connection string"
  type        = string
  sensitive   = true
}

variable "cosmos_endpoint" {
  description = "Cosmos DB account endpoint URL"
  type        = string
}

variable "cosmos_database_name" {
  description = "Cosmos DB database name"
  type        = string
}

variable "key_vault_uri" {
  description = "Key Vault URI"
  type        = string
}

variable "b2c_instance" {
  description = "Azure AD B2C instance URL (e.g. https://treinaidev.b2clogin.com)"
  type        = string
  default     = ""
}

variable "b2c_domain" {
  description = "Azure AD B2C domain (e.g. treinaidev.onmicrosoft.com)"
  type        = string
  default     = ""
}

variable "b2c_client_id" {
  description = "Azure AD B2C application (client) ID"
  type        = string
  default     = ""
}

variable "b2c_policy_id" {
  description = "Azure AD B2C sign-up/sign-in policy name"
  type        = string
  default     = "B2C_1_signupsignin"
}

variable "tags" {
  type = map(string)
}

# One Storage Account shared by all Function Apps in this environment
resource "azurerm_storage_account" "functions" {
  name                     = "${var.project}stfunc${var.environment}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  tags                     = var.tags
}

# One Consumption plan shared by all Function Apps
resource "azurerm_service_plan" "functions" {
  name                = "${var.project}-plan-func-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Windows"
  sku_name            = "Y1" # Consumption

  tags = var.tags
}

# One Function App per microservice
resource "azurerm_windows_function_app" "apps" {
  for_each = toset(var.function_apps)

  name                       = "${var.project}-func-${each.key}-${var.environment}"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  service_plan_id            = azurerm_service_plan.functions.id
  storage_account_name       = azurerm_storage_account.functions.name
  storage_account_access_key = azurerm_storage_account.functions.primary_access_key

  identity {
    type         = "UserAssigned"
    identity_ids = [var.managed_identity_id]
  }

  site_config {
    application_stack {
      dotnet_version              = "v8.0"
      use_dotnet_isolated_runtime = true
    }

    cors {
      allowed_origins = ["*"] # Will be restricted to SWA URL in prod
    }
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"              = "dotnet-isolated"
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = var.app_insights_connection_string
    "AZURE_CLIENT_ID"                       = var.managed_identity_client_id
    "CosmosDb__Endpoint"                    = var.cosmos_endpoint
    "CosmosDb__DatabaseName"                = var.cosmos_database_name
    "CosmosDb__ManagedIdentityClientId"     = var.managed_identity_client_id
    "KeyVault__Uri"                         = var.key_vault_uri
    # Azure AD B2C — populated after B2C tenant is provisioned (E1-07)
    "AzureAdB2C__Instance"            = var.b2c_instance
    "AzureAdB2C__Domain"              = var.b2c_domain
    "AzureAdB2C__ClientId"            = var.b2c_client_id
    "AzureAdB2C__SignUpSignInPolicyId" = var.b2c_policy_id
  }

  tags = var.tags
}

output "function_app_ids" {
  value = { for k, v in azurerm_windows_function_app.apps : k => v.id }
}

output "function_app_hostnames" {
  value = { for k, v in azurerm_windows_function_app.apps : k => v.default_hostname }
}

output "function_app_names" {
  value = { for k, v in azurerm_windows_function_app.apps : k => v.name }
}
