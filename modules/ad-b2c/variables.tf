# ──────────────────────────────────────────────
# Module: Azure AD B2C — Variables
# ──────────────────────────────────────────────

variable "resource_group_name" {
  description = "Resource group where the B2C directory will be registered"
  type        = string
}

variable "b2c_tenant_name" {
  description = "B2C tenant domain prefix (e.g. 'treinaidev' → treinaidev.onmicrosoft.com)"
  type        = string
}

variable "b2c_display_name" {
  description = "Display name of the B2C tenant"
  type        = string
}

variable "b2c_country_code" {
  description = "ISO 3166-1 alpha-2 country code for data residency"
  type        = string
  default     = "BR"
}

variable "sku_name" {
  description = "B2C SKU (PremiumP1 or PremiumP2)"
  type        = string
  default     = "PremiumP1"
}

variable "tags" {
  type    = map(string)
  default = {}
}
