# ──────────────────────────────────────────────
# Module: Cosmos DB Serverless
# ──────────────────────────────────────────────

variable "account_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "database_name" {
  type    = string
  default = "treinai-db"
}

variable "containers" {
  type = list(object({
    name               = string
    partition_key_path = string
  }))
}

variable "tags" {
  type = map(string)
}

resource "azurerm_cosmosdb_account" "this" {
  name                = var.account_name
  resource_group_name = var.resource_group_name
  location            = var.location
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }

  capabilities {
    name = "EnableServerless"
  }

  # Disable key-based access — enforce Managed Identity / RBAC only
  local_authentication_disabled = true

  tags = var.tags
}

resource "azurerm_cosmosdb_sql_database" "this" {
  name                = var.database_name
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.this.name
}

resource "azurerm_cosmosdb_sql_container" "containers" {
  for_each = { for c in var.containers : c.name => c }

  name                = each.value.name
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.this.name
  database_name       = azurerm_cosmosdb_sql_database.this.name
  partition_key_paths = [each.value.partition_key_path]

  indexing_policy {
    indexing_mode = "consistent"

    included_path {
      path = "/*"
    }

    excluded_path {
      path = "/_etag/?"
    }
  }
}

output "id" {
  value = azurerm_cosmosdb_account.this.id
}

output "endpoint" {
  value = azurerm_cosmosdb_account.this.endpoint
}

output "name" {
  value = azurerm_cosmosdb_account.this.name
}

output "database_name" {
  value = azurerm_cosmosdb_sql_database.this.name
}

# Built-in Cosmos DB Data Contributor role definition ID
output "data_contributor_role_id" {
  value = "${azurerm_cosmosdb_account.this.id}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002"
}
