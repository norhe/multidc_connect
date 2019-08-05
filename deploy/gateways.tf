## Google

resource "google_compute_address" "gateways-google-east" {
  count  = "${var.gateways_count}"
  name   = "gateway-east-ipv4-address-${count.index + 1}"
  region = "${var.google_region_1}"
}

resource "cloudflare_record" "gateway-east-google" {
  count  = "${var.gateways_count}"
  domain = "${var.cf_domain}"
  name   = "gateway-east-google-${count.index + 1}.${var.cf_domain}"
  value  = "${google_compute_instance.gateway-east.*.network_interface.0.access_config.0.nat_ip[count.index]}"
  type   = "A"
}

resource "google_compute_instance" "gateway-east" {
  provider     = "google.east"
  count        = "${var.gateways_count}"
  name         = "gateway-east-google-${count.index + 1}"
  hostname     = "gateway-east-google-${count.index + 1}.${var.cf_domain}"
  machine_type = "${var.google_client_machine_type}"
  zone         = "${data.google_compute_zones.east-azs.names[count.index]}"
  can_ip_forward = true

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
      nat_ip = "${element(google_compute_address.gateways-google-east.*.address, count.index)}"
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
    source      = "../files/use_dnsmasq.sh"
    destination = "/tmp/use_dnsmasq.sh"
  }

  provisioner "file" {
    source      = "../files/dnsmasq.conf"
    destination = "/tmp/dnsmasq.conf"
  }

  provisioner "file" {
    source      = "${var.aws_credentials_path}"
    destination = "/tmp/credentials"
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
    source      = "../files/install_gateway.sh"
    destination = "/tmp/install_gateway.sh"
  }

  provisioner "file" {
    source      = "../files/consul.zip"
    destination = "/tmp/consul.zip"
  }

  provisioner "remote-exec" {
    inline = [
      "${var.install_consul}",
      "${local.copy_cert_and_key}",
      "${var.set_consul_client_conf}",
      "${var.install_envconsul}",
      "${var.use_dnsmasq}",
      "${var.install_gateway_proxy}",
      #"${var.sync_envoy}",
    ]
  }
}

resource "google_compute_address" "gateways-google-west" {
  count  = "${var.gateways_count}"
  name   = "gateway-west-ipv4-address-${count.index + 1}"
  region = "${var.google_region_2}"
}

resource "cloudflare_record" "gateway-west-google" {
  count  = "${var.gateways_count}"
  domain = "${var.cf_domain}"
  name   = "gateway-west-google-${count.index + 1}.${var.cf_domain}"
  value  = "${google_compute_instance.gateway-west.*.network_interface.0.access_config.0.nat_ip[count.index]}"
  type   = "A"
}

resource "google_compute_instance" "gateway-west" {
  provider     = "google.west"
  count        = "${var.gateways_count}"
  name         = "gateway-west-google${count.index + 1}"
  hostname     = "gateway-west-google${count.index + 1}.${var.cf_domain}"
  machine_type = "${var.google_client_machine_type}"
  zone         = "${data.google_compute_zones.west-azs.names[count.index]}"

  can_ip_forward = true

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
      nat_ip = "${element(google_compute_address.gateways-google-west.*.address, count.index)}"
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
    content     = "${data.template_file.gce-client-west.rendered}"
    destination = "/tmp/client.hcl"
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
    source      = "${var.aws_credentials_path}"
    destination = "/tmp/credentials"
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
    source      = "../files/install_gateway.sh"
    destination = "/tmp/install_gateway.sh"
  }

  provisioner "file" {
    source      = "../files/consul.zip"
    destination = "/tmp/consul.zip"
  }

  provisioner "remote-exec" {
    inline = [
      "${var.install_consul}",
      "${local.copy_cert_and_key}",
      "${var.set_consul_client_conf}",
      "${var.install_envconsul}",
      "${var.use_dnsmasq}",
      "${var.install_gateway_proxy}",
      #"${var.sync_envoy}",
    ]
  }
}

## Azure

resource "azurerm_network_interface" "gateway-east-nic" {
  count                     = "${var.gateways_count}"
  name                      = "gateway-east-NIC-${count.index + 1}"
  location                  = "${azurerm_resource_group.east-rg.location}"
  resource_group_name       = "${azurerm_resource_group.east-rg.name}"
  network_security_group_id = "${azurerm_network_security_group.east-sg.id}"
  enable_ip_forwarding      = true

  ip_configuration {
    name                          = "gateway-east-NicConfiguration-${count.index + 1}"
    subnet_id                     = "${azurerm_subnet.east-subnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${element(azurerm_public_ip.gateway-east-publicip.*.id, count.index)}"
  }

  tags = {
    ehron-autojoin = "${var.azure_east_dc}"
    owner          = "ehron"
  }
}

resource "azurerm_public_ip" "gateway-east-publicip" {
  count               = "${var.gateways_count}"
  name                = "gateway-east-publicip-${count.index + 1}"
  location            = "${azurerm_resource_group.east-rg.location}"
  resource_group_name = "${azurerm_resource_group.east-rg.name}"
  allocation_method   = "Static"

  tags = {
    owner = "ehron"
  }
}

resource "cloudflare_record" "gateway-east-azure" {
  count  = "${var.gateways_count}"
  domain = "${var.cf_domain}"
  name   = "gateway-east-azure-${count.index + 1}.${var.cf_domain}"
  value  = "${azurerm_public_ip.gateway-east-publicip.*.ip_address[count.index]}"
  type   = "A"
}

resource "azurerm_virtual_machine" "gateways-azure-east" {
  count                 = "${var.gateways_count}"
  name                  = "gateway-east-azure-${count.index + 1}"
  location              = "${azurerm_resource_group.east-rg.location}"
  resource_group_name   = "${azurerm_resource_group.east-rg.name}"
  network_interface_ids = ["${element(azurerm_network_interface.gateway-east-nic.*.id, count.index)}"]
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
    name              = "gateway-east-disk-${count.index + 1}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "gateway-east-azure-${count.index + 1}.${var.cf_domain}"
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
    host  = "${element(azurerm_public_ip.gateway-east-publicip.*.ip_address, count.index)}"
  }

  provisioner "file" {
    content     = "${data.template_file.azure-client-east.rendered}"
    destination = "/tmp/client.hcl"
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
    source      = "${var.aws_credentials_path}"
    destination = "/tmp/credentials"
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
    source      = "../files/install_gateway.sh"
    destination = "/tmp/install_gateway.sh"
  }

  provisioner "file" {
    source      = "../files/consul.zip"
    destination = "/tmp/consul.zip"
  }

  provisioner "remote-exec" {
    inline = [
      "${var.install_consul}",
      "${local.copy_cert_and_key}",
      "${var.set_consul_client_conf}",
      "${var.install_envconsul}",
      "${var.use_dnsmasq}",
      "${var.install_gateway_proxy}",
      #"${var.sync_envoy}",
    ]
  }
}


resource "azurerm_network_interface" "gateway-west-nic" {
  count                     = "${var.gateways_count}"
  name                      = "gateway-west-NIC-${count.index + 1}"
  location                  = "${azurerm_resource_group.west-rg.location}"
  resource_group_name       = "${azurerm_resource_group.west-rg.name}"
  network_security_group_id = "${azurerm_network_security_group.west-sg.id}"
  enable_ip_forwarding      = true

  ip_configuration {
    name                          = "gateway-west-NicConfiguration-${count.index + 1}"
    subnet_id                     = "${azurerm_subnet.west-subnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${element(azurerm_public_ip.gateway-west-publicip.*.id, count.index)}"
  }

  tags = {
    ehron-autojoin = "${var.azure_west_dc}"
    owner          = "ehron"
  }
}

resource "azurerm_public_ip" "gateway-west-publicip" {
  count               = "${var.gateways_count}"
  name                = "gateway-west-publicip-${count.index + 1}"
  location            = "${azurerm_resource_group.west-rg.location}"
  resource_group_name = "${azurerm_resource_group.west-rg.name}"
  allocation_method   = "Static"

  tags = {
    owner = "ehron"
  }
}

resource "cloudflare_record" "gateway-west-azure" {
  count  = "${var.gateways_count}"
  domain = "${var.cf_domain}"
  name   = "gateway-west-azure-${count.index + 1}.${var.cf_domain}"
  value  = "${azurerm_public_ip.gateway-west-publicip.*.ip_address[count.index]}"
  type   = "A"
}

resource "azurerm_virtual_machine" "gateway-azure-west" {
  count                 = "${var.gateways_count}"
  name                  = "gateway-west-azure-${count.index+1}"
  location              = "${azurerm_resource_group.west-rg.location}"
  resource_group_name   = "${azurerm_resource_group.west-rg.name}"
  network_interface_ids = ["${element(azurerm_network_interface.gateway-west-nic.*.id, count.index)}"]
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
    name              = "gateway-west-disk-${count.index + 1}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "gateway-west-azure-${count.index + 1}.${var.cf_domain}"
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
    host  = "${element(azurerm_public_ip.gateway-west-publicip.*.ip_address, count.index)}"
  }

  provisioner "file" {
    content     = "${data.template_file.azure-client-west.rendered}"
    destination = "/tmp/client.hcl"
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
    source      = "${var.aws_credentials_path}"
    destination = "/tmp/credentials"
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
    source      = "../files/install_gateway.sh"
    destination = "/tmp/install_gateway.sh"
  }

  provisioner "file" {
    source      = "../files/consul.zip"
    destination = "/tmp/consul.zip"
  }

  provisioner "remote-exec" {
    inline = [
      "${var.install_consul}",
      "${local.copy_cert_and_key}",
      "${var.set_consul_client_conf}",
      "${var.install_envconsul}",
      "${var.use_dnsmasq}",
      "${var.install_gateway_proxy}",
      //"${var.sync_envoy}",
    ]
  }
}