# ──────────────────────────────────────────────
# Outputs — treinAI Infrastructure
# ──────────────────────────────────────────────

output "resource_group_name" {
  value = module.resource_group.name
}

output "managed_identity_client_id" {
  value = module.managed_identity.client_id
}

output "managed_identity_principal_id" {
  value = module.managed_identity.principal_id
}

output "cosmos_endpoint" {
  value = module.cosmos_db.endpoint
}

output "cosmos_database_name" {
  value = module.cosmos_db.database_name
}

output "key_vault_uri" {
  value = module.key_vault.vault_uri
}

output "app_insights_connection_string" {
  value     = module.app_insights.connection_string
  sensitive = true
}

output "static_web_app_hostname" {
  value = module.static_web_app.default_host_name
}

output "static_web_app_api_key" {
  value     = module.static_web_app.api_key
  sensitive = true
}

output "function_app_hostnames" {
  value = module.functions.function_app_hostnames
}
