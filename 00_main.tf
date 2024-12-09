# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.13.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = local.resource_group_name
    storage_account_name = local.storage_account_name
    container_name       = local.container_name
    key                  = local.tfstate_file_name
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  resource_provider_registrations = "none"
  features {}
}

# Connect to the resource group
data "azurerm_resource_group" "rg" {
  name = local.resource_group_name
}

# Connect to the key vault
data "azurerm_key_vault" "kv" {
  name                = local.key_vault_name
  resource_group_name = local.resource_group_name
}

# Get values from the key vault inside the above rg
data "azurerm_key_vault_secret" "ladmin_un" {
  key_vault_id = data.azurerm_key_vault.kv.id
  name         = local.kv_key_name_1
}

data "azurerm_key_vault_secret" "ladmin_pwd" {
  key_vault_id = data.azurerm_key_vault.kv.id
  name         = local.kv_key_name_2
}
