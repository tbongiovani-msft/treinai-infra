terraform {
  backend "azurerm" {
    resource_group_name  = "rg-treinai-tfstate"
    storage_account_name = "sttreinaitfstate"
    container_name       = "tfstate"
    key                  = "treinai.terraform.tfstate"
    use_oidc             = true
  }
}
