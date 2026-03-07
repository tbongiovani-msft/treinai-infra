# ──────────────────────────────────────────────
# Module: Azure AD B2C Directory (E1-07)
# ──────────────────────────────────────────────
# Creates the B2C directory resource. After terraform apply,
# manually configure user flows (Sign-up/Sign-in) in the Azure Portal:
#   1. Add "Sign up and sign in" user flow (B2C_1_signupsignin)
#   2. Add application registration (SPA + redirect URIs)
#   3. Add custom claims: extension_Role, extension_TenantId
# ──────────────────────────────────────────────

resource "azurerm_aadb2c_directory" "this" {
  country_code            = var.b2c_country_code
  data_residency_location = "Latin America"
  display_name            = var.b2c_display_name
  domain_name             = "${var.b2c_tenant_name}.onmicrosoft.com"
  resource_group_name     = var.resource_group_name
  sku_name                = var.sku_name

  tags = var.tags
}
