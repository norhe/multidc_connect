## Google

resource "google_compute_network" "app_network" {
  name                    = "app-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "east-subnet" {
  name          = "east-subnet"
  region        = "${var.google_region_1}"
  ip_cidr_range = "10.3.0.0/16"
  network       = "${google_compute_network.app_network.self_link}"
}

resource "google_compute_subnetwork" "west-subnet" {
  name          = "west-subnet"
  region        = "${var.google_region_2}"
  ip_cidr_range = "10.4.0.0/16"
  network       = "${google_compute_network.app_network.self_link}"
}

resource "google_compute_firewall" "gcp-allow-traffic" {
  name    = "${google_compute_network.app_network.name}-gcp-allow-traffic"
  network = "${google_compute_network.app_network.name}"

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "8080", "8300", "8302"]
  }

  source_ranges = [
    "0.0.0.0/0"
  ]
}

resource "google_compute_firewall" "allow-consul" {
  name    = "hc-traffic"
  network = "${google_compute_network.app_network.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["8200", "8300", "8301", "8302", "8500", "8600"]
  }
}

resource "google_compute_firewall" "allow-consul-wan-east" {
  name    = "consul-wan-east-1"
  network = "${google_compute_network.app_network.self_link}"

  allow {
    protocol = "udp"
    ports    = ["8301", "8302", "8600"]
  }
}

resource "google_compute_firewall" "allow-internal" {
  name    = "http-east-1"
  network = "${google_compute_network.app_network.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = [
    "10.0.0.0/8"
  ]
}

## Azure
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
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_ranges    = ["22", "8300-8302", "8500", "8600"]
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
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_ranges    = ["22", "8300-8302", "8500", "8600"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  #tags {
  #    environment = "Terraform Demo"
  #}
}

## VPN

