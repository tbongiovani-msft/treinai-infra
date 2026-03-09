# ══════════════════════════════════════════════════════════════
# Terraform Import Blocks
# ══════════════════════════════════════════════════════════════
# These import blocks bring existing Azure resources into the
# Terraform state. They are safe to remove after a successful
# terraform apply.
# ══════════════════════════════════════════════════════════════

locals {
  cosmos_base_id = "/subscriptions/247f1805-23e4-49df-8359-ce71728346a3/resourceGroups/rg-treinai-dev/providers/Microsoft.DocumentDB/databaseAccounts/treinai-cosmos-dev/sqlDatabases/treinai-db/containers"
}

import {
  to = module.cosmos_db.azurerm_cosmosdb_sql_container.containers["alunos"]
  id = "${local.cosmos_base_id}/alunos"
}

import {
  to = module.cosmos_db.azurerm_cosmosdb_sql_container.containers["historico-peso"]
  id = "${local.cosmos_base_id}/historico-peso"
}

import {
  to = module.cosmos_db.azurerm_cosmosdb_sql_container.containers["planos-nutricionais"]
  id = "${local.cosmos_base_id}/planos-nutricionais"
}
