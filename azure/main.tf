# Configure the Azure Provider
provider "azurerm" {
  subscription_id = "14692f20-9428-451b-8298-102ed4e39c2a"
}

resource "azurerm_resource_group" "west-rg" {
  name     = "west-deployment"
  location = "West US"
}

resource "azurerm_resource_group" "east-rg" {
  name     = "east-deployment"
  location = "East US"
}