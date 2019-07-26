# Google
resource "google_compute_instance" "listings-east" {
  provider     = "google.east"
  count        = "${var.listings_count}"
  name         = "listing-east-${count.index + 1}"
  machine_type = "${var.google_client_machine_type}"
  zone         = "${data.google_compute_zones.east-azs.names[count.index]}"

  tags = [
    "consul-east-dc",
  ]

  boot_disk {
    initialize_params {
      image = "ubuntu-1804-lts"
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.east-subnet.self_link}"

    access_config {
      // ephemeral public IP
    }
  }

  metadata = {
    sshKeys = "${var.ssh_user}:${var.ssh_public_key}"
  }

  lifecycle {
    create_before_destroy = true
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/compute.readonly"]
  }

  allow_stopping_for_update = true

  connection {
    user        = "ehron"
    private_key = "${file(var.ssh_private_key_path)}"
    type        = "ssh"
    host        = "${self.network_interface.0.access_config.0.nat_ip}"
  }

  provisioner "file" {
    #source      = "../files/gce-client-east.hcl"
    content     = "${data.template_file.gce-client-east.rendered}"
    destination = "/tmp/client.hcl"
  }

  provisioner "file" {
    source      = "../files/services/listing_pq.hcl"
    destination = "/tmp/listing_pq.hcl"
  }

  provisioner "file" {
    source      = "../files/services/listing_svc.hcl"
    destination = "/tmp/listing_svc.hcl"
  }
  provisioner "file" {
    source      = "../files/use_dnsmasq.sh"
    destination = "/tmp/use_dnsmasq.sh"
  }

  provisioner "file" {
    source      = "../files/dnsmasq.conf"
    destination = "/tmp/dnsmasq.conf"
  }

  provisioner "file" {
    source      = "../files/install_envoy.sh"
    destination = "/tmp/install_envoy.sh"
  }

  provisioner "file" {
    source      = "../files/install_consul_proxy.sh"
    destination = "/tmp/install_consul_proxy.sh"
  }

  provisioner "file" {
    source      = "${var.aws_credentials_path}"
    destination = "/tmp/credentials"
  }

  provisioner "remote-exec" {
    inline = [
      "${var.install_consul}",
      "${var.set_consul_client_conf}",
      "${var.set_consul_listing_conf}",
      "${var.install_envconsul}",
      "${var.use_dnsmasq}",
      "${var.install_listing_and_proxy}"
      #"${var.sync_envoy}",
    ]
  }
}

resource "google_compute_instance" "listings-west" {
  provider     = "google.west"
  count        = "${var.listings_count}"
  name         = "listing-west-${count.index + 1}"
  machine_type = "${var.google_client_machine_type}"
  zone         = "${data.google_compute_zones.west-azs.names[count.index]}"

  tags = [
    "consul-west-dc",
  ]

  boot_disk {
    initialize_params {
      image = "ubuntu-1804-lts"
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.west-subnet.self_link}"

    access_config {
      // ephemeral public IP
    }
  }

  metadata = {
    sshKeys = "${var.ssh_user}:${var.ssh_public_key}"
  }

  lifecycle {
    create_before_destroy = true
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/compute.readonly"]
  }

  allow_stopping_for_update = true

  connection {
    user        = "ehron"
    private_key = "${file(var.ssh_private_key_path)}"
    type        = "ssh"
    host        = "${self.network_interface.0.access_config.0.nat_ip}"
  }

  provisioner "file" {
    #source      = "../files/gce-client-west.hcl"
    content     = "${data.template_file.gce-client-west.rendered}"
    destination = "/tmp/client.hcl"
  }

  provisioner "file" {
    source      = "../files/services/listing_pq.hcl"
    destination = "/tmp/listing_pq.hcl"
  }

  provisioner "file" {
    source      = "../files/services/listing_svc.hcl"
    destination = "/tmp/listing_svc.hcl"
  }
  provisioner "file" {
    source      = "../files/use_dnsmasq.sh"
    destination = "/tmp/use_dnsmasq.sh"
  }

  provisioner "file" {
    source      = "../files/dnsmasq.conf"
    destination = "/tmp/dnsmasq.conf"
  }

  provisioner "file" {
    source      = "../files/install_envoy.sh"
    destination = "/tmp/install_envoy.sh"
  }

  provisioner "file" {
    source      = "../files/install_consul_proxy.sh"
    destination = "/tmp/install_consul_proxy.sh"
  }

  provisioner "file" {
    source      = "${var.aws_credentials_path}"
    destination = "/tmp/credentials"
  }

  provisioner "remote-exec" {
    inline = [
      "${var.install_consul}",
      "${var.set_consul_client_conf}",
      "${var.set_consul_listing_conf}",
      "${var.install_envconsul}",
      "${var.use_dnsmasq}",
      "${var.install_listing_and_proxy}"
      #"${var.sync_envoy}",
    ]
  }
}

# Azure


resource "azurerm_network_interface" "listing-east-nic" {
  count                     = "${var.listings_count}"
  name                      = "listing-east-NIC-${count.index}"
  location                  = "${azurerm_resource_group.east-rg.location}"
  resource_group_name       = "${azurerm_resource_group.east-rg.name}"
  network_security_group_id = "${azurerm_network_security_group.east-sg.id}"

  ip_configuration {
    name                          = "listing-east-NicConfiguration-${count.index}"
    subnet_id                     = "${azurerm_subnet.east-subnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${element(azurerm_public_ip.listing-east-publicip.*.id, count.index)}"
  }

  tags = {
    ehron-autojoin  = "${var.azure_east_dc}"
    owner           = "ehron"
  }
}

resource "azurerm_public_ip" "listing-east-publicip" {
  count               = "${var.listings_count}"
  name                = "listing-east-publicip-${count.index}"
  location            = "${azurerm_resource_group.east-rg.location}"
  resource_group_name = "${azurerm_resource_group.east-rg.name}"
  allocation_method   = "Static"

  tags = {
    owner = "ehron"
  }
}

resource "azurerm_virtual_machine" "listing-east" {
  count                 = "${var.listings_count}"
  name                  = "listing-east-${count.index}"
  location              = "${azurerm_resource_group.east-rg.location}"
  resource_group_name   = "${azurerm_resource_group.east-rg.name}"
  network_interface_ids = ["${element(azurerm_network_interface.listing-east-nic.*.id, count.index)}"]
  vm_size               = "${var.azure_client_machine_type}"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "listing-east-disk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "listing-east-${count.index}"
    admin_username = "${var.ssh_user}"
    admin_password = "${var.host_pw}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
    ssh_keys {
      key_data = "${var.ssh_public_key}"
      path     = "/home/${var.ssh_user}/.ssh/authorized_keys"
    }
  }

  connection {
    user     = "${var.ssh_user}"
    password = "${var.host_pw}"
    #private_key = "${file(var.ssh_private_key_path)}"
    agent = false
    type  = "ssh"
    host  = "${element(azurerm_public_ip.listing-east-publicip.*.ip_address, count.index)}"
  }

  provisioner "file" {
    content     = "${data.template_file.azure-client-east.rendered}"
    destination = "/tmp/client.hcl"
  }

  provisioner "file" {
    source      = "../files/services/listing_pq.hcl"
    destination = "/tmp/listing_pq.hcl"
  }

  provisioner "file" {
    source      = "../files/services/listing_svc.hcl"
    destination = "/tmp/listing_svc.hcl"
  }
  provisioner "file" {
    source      = "../files/use_dnsmasq.sh"
    destination = "/tmp/use_dnsmasq.sh"
  }

  provisioner "file" {
    source      = "../files/dnsmasq.conf"
    destination = "/tmp/dnsmasq.conf"
  }

  provisioner "file" {
    source      = "../files/install_envoy.sh"
    destination = "/tmp/install_envoy.sh"
  }

  provisioner "file" {
    source      = "../files/install_consul_proxy.sh"
    destination = "/tmp/install_consul_proxy.sh"
  }

  provisioner "file" {
    source      = "${var.aws_credentials_path}"
    destination = "/tmp/credentials"
  }

  provisioner "remote-exec" {
    inline = [
      "${var.install_consul}",
      "${var.set_consul_client_conf}",
      "${var.set_consul_listing_conf}",
      "${var.install_envconsul}",
      "${var.use_dnsmasq}",
      "${var.install_listing_and_proxy}"
      #"${var.sync_envoy}",
    ]
  }
}

resource "azurerm_network_interface" "listing-west-nic" {
  count                     = "${var.listings_count}"
  name                      = "listing-west-NIC-${count.index}"
  location                  = "${azurerm_resource_group.west-rg.location}"
  resource_group_name       = "${azurerm_resource_group.west-rg.name}"
  network_security_group_id = "${azurerm_network_security_group.west-sg.id}"

  ip_configuration {
    name                          = "listing-west-NicConfiguration-${count.index}"
    subnet_id                     = "${azurerm_subnet.west-subnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${element(azurerm_public_ip.listing-west-publicip.*.id, count.index)}"
  }

  tags = {
    ehron-autojoin  = "${var.azure_west_dc}"
    owner           = "ehron"
  }
}

resource "azurerm_public_ip" "listing-west-publicip" {
  count               = "${var.listings_count}"
  name                = "listing-west-publicip-${count.index}"
  location            = "${azurerm_resource_group.west-rg.location}"
  resource_group_name = "${azurerm_resource_group.west-rg.name}"
  allocation_method   = "Static"

  tags = {
    owner = "ehron"
  }
}

resource "azurerm_virtual_machine" "listing-west" {
  count                 = "${var.listings_count}"
  name                  = "listing-west-${count.index}"
  location              = "${azurerm_resource_group.west-rg.location}"
  resource_group_name   = "${azurerm_resource_group.west-rg.name}"
  network_interface_ids = ["${element(azurerm_network_interface.listing-west-nic.*.id, count.index)}"]
  vm_size               = "${var.azure_client_machine_type}"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "listing-west-disk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "listing-west-${count.index}"
    admin_username = "${var.ssh_user}"
    admin_password = "${var.host_pw}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
    ssh_keys {
      key_data = "${var.ssh_public_key}"
      path     = "/home/${var.ssh_user}/.ssh/authorized_keys"
    }
  }

  connection {
    user     = "${var.ssh_user}"
    password = "${var.host_pw}"
    #private_key = "${file(var.ssh_private_key_path)}"
    agent = false
    type  = "ssh"
    host  = "${element(azurerm_public_ip.listing-west-publicip.*.ip_address, count.index)}"
  }

  provisioner "file" {
    content     = "${data.template_file.azure-client-west.rendered}"
    destination = "/tmp/client.hcl"
  }

  provisioner "file" {
    source      = "../files/services/listing_pq.hcl"
    destination = "/tmp/listing_pq.hcl"
  }

  provisioner "file" {
    source      = "../files/services/listing_svc.hcl"
    destination = "/tmp/listing_svc.hcl"
  }
  provisioner "file" {
    source      = "../files/use_dnsmasq.sh"
    destination = "/tmp/use_dnsmasq.sh"
  }

  provisioner "file" {
    source      = "../files/dnsmasq.conf"
    destination = "/tmp/dnsmasq.conf"
  }

  provisioner "file" {
    source      = "../files/install_envoy.sh"
    destination = "/tmp/install_envoy.sh"
  }

  provisioner "file" {
    source      = "../files/install_consul_proxy.sh"
    destination = "/tmp/install_consul_proxy.sh"
  }

  provisioner "file" {
    source      = "${var.aws_credentials_path}"
    destination = "/tmp/credentials"
  }

  provisioner "remote-exec" {
    inline = [
      "${var.install_consul}",
      "${var.set_consul_client_conf}",
      "${var.set_consul_listing_conf}",
      "${var.install_envconsul}",
      "${var.use_dnsmasq}",
      "${var.install_listing_and_proxy}"
      #"${var.sync_envoy}",
    ]
  }
}