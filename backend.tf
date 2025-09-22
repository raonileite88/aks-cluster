## Remote backend configuration for Azure
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-aks-terraform-state"
    storage_account_name = "tfstatestorageaccountaks"
    container_name       = "tfstate"
    key                  = "aks-cluster/prod/terraform.tfstate"
  }
}