# Configure the Azure Provider
provider "azurerm" {}

resource "azurerm_resource_group" "west-rg" {
  name     = "west-deployment"
  location = "West US"
}

resource "azurerm_resource_group" "east-rg" {
  name     = "east-deployment"
  location = "East US"
}