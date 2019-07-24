resource "azurerm_virtual_network" "west-network" {
  name                = "acctvn"
  address_space       = ["10.1.0.0/16"]
  location            = "${azurerm_resource_group.west-rg.location}"
  resource_group_name = "${azurerm_resource_group.west-rg.name}"
}

resource "azurerm_subnet" "west-subnet" {
  name                 = "acctsub"
  resource_group_name  = "${azurerm_resource_group.west-rg.name}"
  virtual_network_name = "${azurerm_virtual_network.west-network.name}"
  address_prefix       = "10.1.1.0/24"
}

resource "azurerm_virtual_network" "east-network" {
  name                = "acctvn"
  address_space       = ["10.2.0.0/16"]
  location            = "${azurerm_resource_group.east-rg.location}"
  resource_group_name = "${azurerm_resource_group.east-rg.name}"
}

resource "azurerm_subnet" "east-subnet" {
  name                 = "acctsub"
  resource_group_name  = "${azurerm_resource_group.east-rg.name}"
  virtual_network_name = "${azurerm_virtual_network.east-network.name}"
  address_prefix       = "10.2.1.0/24"
}

resource "azurerm_virtual_network_peering" "east-to-west" {
  name                         = "east-to-west-peering"
  resource_group_name          = "${azurerm_resource_group.east-rg.name}"
  virtual_network_name         = "${azurerm_virtual_network.east-network.name}"
  remote_virtual_network_id    = "${azurerm_virtual_network.west-network.id}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "west-to-east" {
  name                         = "west-to-east-peering"
  resource_group_name          = "${azurerm_resource_group.west-rg.name}"
  virtual_network_name         = "${azurerm_virtual_network.west-network.name}"
  remote_virtual_network_id    = "${azurerm_virtual_network.east-network.id}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_network_security_group" "west-sg" {
  name                = "west-sg"
  location            = "${azurerm_resource_group.west-rg.location}"
  resource_group_name = "${azurerm_resource_group.west-rg.name}"

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  #tags {
  #environment = "Terraform Demo"
  #}
}

resource "azurerm_network_security_group" "east-sg" {
  name                = "east-sg"
  location            = "${azurerm_resource_group.east-rg.location}"
  resource_group_name = "${azurerm_resource_group.east-rg.name}"

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  #tags {
  #    environment = "Terraform Demo"
  #}
}