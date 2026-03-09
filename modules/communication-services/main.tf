# ──────────────────────────────────────────────
# Module: Azure Communication Services + Email
# Provisions ACS resource, Email Communication Service,
# and Azure-managed email domain (*.azurecomm.net).
# ──────────────────────────────────────────────

variable "name" {
  description = "Name for the Communication Services resource"
  type        = string
}

variable "email_name" {
  description = "Name for the Email Communication Service resource"
  type        = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  description = "Location for the Email Communication Service (ACS is global)"
  type        = string
}

variable "data_location" {
  description = "Data location for ACS (e.g., Brazil)"
  type        = string
  default     = "Brazil"
}

variable "tags" {
  type = map(string)
}

# ──────────────────────────────────────────────
# 1. Azure Communication Services (Global)
# ──────────────────────────────────────────────
resource "azurerm_communication_service" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  data_location       = var.data_location
  tags                = var.tags
}

# ──────────────────────────────────────────────
# 2. Email Communication Service
# ──────────────────────────────────────────────
resource "azurerm_email_communication_service" "this" {
  name                = var.email_name
  resource_group_name = var.resource_group_name
  data_location       = var.data_location
  tags                = var.tags
}

# ──────────────────────────────────────────────
# 3. Azure-Managed Email Domain (*.azurecomm.net)
#    No custom domain verification needed — ready to send immediately.
# ──────────────────────────────────────────────
resource "azurerm_email_communication_service_domain" "azure_managed" {
  name             = "AzureManagedDomain"
  email_service_id = azurerm_email_communication_service.this.id
  domain_management = "AzureManaged"

  # Sender usernames are auto-configured by Azure for managed domains
  # Default sender: DoNotReply@<guid>.azurecomm.net
}

# ──────────────────────────────────────────────
# 4. Link Email Domain to Communication Service
# ──────────────────────────────────────────────
resource "azurerm_communication_service_email_domain_association" "this" {
  communication_service_id = azurerm_communication_service.this.id
  email_service_domain_id  = azurerm_email_communication_service_domain.azure_managed.id
}

# ──────────────────────────────────────────────
# Outputs
# ──────────────────────────────────────────────
output "id" {
  value = azurerm_communication_service.this.id
}

output "name" {
  value = azurerm_communication_service.this.name
}

output "primary_connection_string" {
  description = "Primary connection string for ACS (for Key Vault storage)"
  value       = azurerm_communication_service.this.primary_connection_string
  sensitive   = true
}

output "email_service_id" {
  value = azurerm_email_communication_service.this.id
}

output "email_domain_name" {
  description = "Azure-managed email domain (e.g., guid.azurecomm.net)"
  value       = azurerm_email_communication_service_domain.azure_managed.from_sender_domain
}

output "email_sender_address" {
  description = "Default sender address (DoNotReply@domain)"
  value       = "DoNotReply@${azurerm_email_communication_service_domain.azure_managed.from_sender_domain}"
}
