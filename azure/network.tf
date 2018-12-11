resource "azurerm_virtual_network" "west-network" {
 name                = "acctvn"
 address_space       = ["10.0.0.0/16"]
 location            = "${azurerm_resource_group.west-rg.location}"
 resource_group_name = "${azurerm_resource_group.west-rg.name}"
}

resource "azurerm_subnet" "west-subnet" {
 name                 = "acctsub"
 resource_group_name  = "${azurerm_resource_group.west-rg.name}"
 virtual_network_name = "${azurerm_virtual_network.west-network.name}"
 address_prefix       = "10.0.2.0/24"
}

resource "azurerm_virtual_network" "east-network" {
 name                = "acctvn"
 address_space       = ["10.0.0.0/16"]
 location            = "${azurerm_resource_group.east-rg.location}"
 resource_group_name = "${azurerm_resource_group.east-rg.name}"
}

resource "azurerm_subnet" "east-subnet" {
 name                 = "acctsub"
 resource_group_name  = "${azurerm_resource_group.east-rg.name}"
 virtual_network_name = "${azurerm_virtual_network.east-network.name}"
 address_prefix       = "10.0.3.0/24"
}

# Create Network Security Group and rule
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

    tags {
        environment = "Terraform Demo"
    }
}