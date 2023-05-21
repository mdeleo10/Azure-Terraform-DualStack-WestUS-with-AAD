terraform {
  required_providers {
    azurerm = {
        source  = "hashicorp/azurerm"
        version = "=3.0.0"
    }
  }
  backend "azurerm" {
    resource_group_name     = "rg-terraform-state-001"
    storage_account_name    = "cloudmdterraformstate"
    container_name          = "tfstate"
    key                     = "tfstate"
  }
}
provider "azurerm" {
  features {}
}
