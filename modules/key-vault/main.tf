# ──────────────────────────────────────────────
# Module: Key Vault
# ──────────────────────────────────────────────

variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "tags" {
  type = map(string)
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name                       = var.name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  tenant_id                  = var.tenant_id
  sku_name                   = "standard"
  purge_protection_enabled   = false
  soft_delete_retention_days = 7
  rbac_authorization_enabled      = true
  tags                       = var.tags
}

# Grant the deployer (current user/SP) Key Vault Administrator role
resource "azurerm_role_assignment" "deployer_kv_admin" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

output "id" {
  value = azurerm_key_vault.this.id
}

output "vault_uri" {
  value = azurerm_key_vault.this.vault_uri
}

output "name" {
  value = azurerm_key_vault.this.name
}
