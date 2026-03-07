# ──────────────────────────────────────────────
# Module: Azure AD B2C — Outputs
# ──────────────────────────────────────────────

output "tenant_id" {
  description = "The B2C tenant ID"
  value       = azurerm_aadb2c_directory.this.tenant_id
}

output "domain_name" {
  description = "The B2C domain name (e.g. treinaidev.onmicrosoft.com)"
  value       = azurerm_aadb2c_directory.this.domain_name
}

output "effective_domain_name" {
  description = "The effective domain name (same as domain_name)"
  value       = azurerm_aadb2c_directory.this.effective_domain_name
}
