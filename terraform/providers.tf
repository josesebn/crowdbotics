terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~>2.30"
    }
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>3.106"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
 }