terraform {
  required_version = "~> 1.6"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.107"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 1.13"
    }
  }
  backend "azurerm" {
    use_azuread_auth     = true
    resource_group_name  = "rg-alz-mgmt-state-germanywestcentral-001"
    storage_account_name = "stoalzmgmger001zjln"
    container_name       = "mgmt-tfstate"
    key                  = "terraform.tfstate"
    subscription_id      = "4896a771-b1ab-4411-bd94-3c8467f1991e"
    tenant_id            = "ade68923-b72b-4190-8508-a19a58692001"
  }
}

provider "azapi" {
  skip_provider_registration = true
  subscription_id            = var.subscription_id_management
}

provider "azurerm" {
  skip_provider_registration = true
  features {}
}

provider "azurerm" {
  skip_provider_registration = true
  alias                      = "management"
  subscription_id            = var.subscription_id_management
  features {}
}

provider "azurerm" {
  skip_provider_registration = true
  alias                      = "connectivity"
  subscription_id            = var.subscription_id_connectivity
  features {}
}

provider "azurerm" {
  alias           = "identity"
  subscription_id = var.subscription_id_identity
  features {}
}
