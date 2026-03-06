# ══════════════════════════════════════════════════════════════
# treinAI — Infrastructure as Code (Root Module)
# ══════════════════════════════════════════════════════════════
# Usage:
#   terraform init
#   terraform plan  -var-file="environments/dev.tfvars"
#   terraform apply -var-file="environments/dev.tfvars"
# ══════════════════════════════════════════════════════════════

locals {
  # Standard tags applied to ALL resources
  tags = {
    project     = var.project
    environment = var.environment
    owner       = var.owner
    managed_by  = "terraform"
    cost_center = "treinai-${var.environment}"
  }

  # Naming convention: treinai-{resource}-{env}
  rg_name       = "rg-${var.project}-${var.environment}"
  identity_name = "${var.project}-identity-${var.environment}"
  cosmos_name   = "${var.project}-cosmos-${var.environment}"
  kv_name       = "${var.project}-kv-${var.environment}"
  appi_name     = "${var.project}-appi-${var.environment}"
  swa_name      = "${var.project}-swa-${var.environment}"
}

data "azurerm_client_config" "current" {}

# ──────────────────────────────────────────────
# 1. Resource Group (E1-02)
# ──────────────────────────────────────────────
module "resource_group" {
  source   = "./modules/resource-group"
  name     = local.rg_name
  location = var.location
  tags     = local.tags
}

# ──────────────────────────────────────────────
# 2. User-Assigned Managed Identity (E1-12)
# ──────────────────────────────────────────────
module "managed_identity" {
  source              = "./modules/managed-identity"
  name                = local.identity_name
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tags                = local.tags
}

# ──────────────────────────────────────────────
# 3. Application Insights + Log Analytics (E1-06)
# ──────────────────────────────────────────────
module "app_insights" {
  source              = "./modules/app-insights"
  name                = local.appi_name
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tags                = local.tags
}

# ──────────────────────────────────────────────
# 4. Key Vault (E1-08)
# ──────────────────────────────────────────────
module "key_vault" {
  source              = "./modules/key-vault"
  name                = local.kv_name
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  tags                = local.tags
}

# ──────────────────────────────────────────────
# 5. Cosmos DB Serverless (E1-05)
# ──────────────────────────────────────────────
module "cosmos_db" {
  source              = "./modules/cosmos-db"
  account_name        = local.cosmos_name
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  containers          = var.cosmos_db_containers
  tags                = local.tags
}

# ──────────────────────────────────────────────
# 6. Azure Functions — 7 Microservices (E1-04)
# ──────────────────────────────────────────────
module "functions" {
  source                         = "./modules/functions"
  function_apps                  = var.function_apps
  resource_group_name            = module.resource_group.name
  location                       = module.resource_group.location
  project                        = var.project
  environment                    = var.environment
  managed_identity_id            = module.managed_identity.id
  managed_identity_client_id     = module.managed_identity.client_id
  app_insights_connection_string = module.app_insights.connection_string
  cosmos_endpoint                = module.cosmos_db.endpoint
  cosmos_database_name           = module.cosmos_db.database_name
  key_vault_uri                  = module.key_vault.vault_uri
  tags                           = local.tags
}

# ──────────────────────────────────────────────
# 7. Azure Static Web App (E1-03)
# ──────────────────────────────────────────────
module "static_web_app" {
  source              = "./modules/static-web-app"
  name                = local.swa_name
  resource_group_name = module.resource_group.name
  location            = "eastus2" # SWA not available in brazilsouth
  tags                = local.tags
}

# ══════════════════════════════════════════════════════════════
# RBAC Assignments — Managed Identity → Azure Resources
# ══════════════════════════════════════════════════════════════

# ──────────────────────────────────────────────
# E1-13: Cosmos DB Built-in Data Contributor
# ──────────────────────────────────────────────
resource "azurerm_cosmosdb_sql_role_assignment" "identity_cosmos" {
  resource_group_name = module.resource_group.name
  account_name        = module.cosmos_db.name
  role_definition_id  = module.cosmos_db.data_contributor_role_id
  principal_id        = module.managed_identity.principal_id
  scope               = module.cosmos_db.id
}

# ──────────────────────────────────────────────
# E1-14: Key Vault Secrets User
# ──────────────────────────────────────────────
resource "azurerm_role_assignment" "identity_kv_secrets" {
  scope                = module.key_vault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.managed_identity.principal_id
}

# ──────────────────────────────────────────────
# E1-15: Monitoring Metrics Publisher (App Insights)
# ──────────────────────────────────────────────
resource "azurerm_role_assignment" "identity_monitoring" {
  scope                = module.app_insights.id
  role_definition_name = "Monitoring Metrics Publisher"
  principal_id         = module.managed_identity.principal_id
}

# ──────────────────────────────────────────────
# Grant deployer Cosmos DB Data Contributor (for local dev/seeding)
# ──────────────────────────────────────────────
resource "azurerm_cosmosdb_sql_role_assignment" "deployer_cosmos" {
  resource_group_name = module.resource_group.name
  account_name        = module.cosmos_db.name
  role_definition_id  = module.cosmos_db.data_contributor_role_id
  principal_id        = data.azurerm_client_config.current.object_id
  scope               = module.cosmos_db.id
}

