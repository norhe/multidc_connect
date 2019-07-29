## Google
resource "google_compute_address" "servers-east" {
  count  = "${var.servers_count}"
  name   = "server-east-ipv4-address-${count.index + 1}"
  region = "${var.google_region_1}"
}

resource "cloudflare_record" "servers-east-google" {
  count  = "${var.servers_count}"
  domain = "${var.cf_domain}"
  name   = "server-east-google-${count.index + 1}.${var.cf_domain}"
  value  = "${google_compute_instance.servers-east.*.network_interface.0.access_config.0.nat_ip[count.index]}"
  type   = "A"
}

resource "google_compute_instance" "servers-east" {
  provider     = "google.east"
  count        = "${var.servers_count}"
  name         = "server-east-google-${count.index + 1}"
  hostname     = "server-east-google-${count.index + 1}.${var.cf_domain}"
  machine_type = "${var.google_server_machine_type}"
  zone         = "${data.google_compute_zones.east-azs.names[count.index]}"

  tags = [
    "consul-server",
    "consul-east-gcp"
  ]

  boot_disk {
    initialize_params {
      image = "ubuntu-1804-lts"
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.east-subnet.self_link}"

    access_config {
      nat_ip = "${element(google_compute_address.servers-east.*.address, count.index)}"
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
    #source      = "../files/gce-server-east.hcl"
    content     = "${data.template_file.gce-server-east.rendered}"
    destination = "/tmp/server.hcl"
  }

  #provisioner "file" {
  #  source      = "../files/consul.zip"
  #  destination = "/tmp/consul.zip"
  #}

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
    source      = "../files/seed_consul.sh"
    destination = "/tmp/seed_consul.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "${var.install_consul}",
      "${var.install_envconsul}",
      "${local.copy_cert_and_key}",
      "${var.set_consul_server_conf}",
      "${var.change_adver_addr_google}",
      "sudo systemctl restart consul",
      "${var.use_dnsmasq}",
      "sleep 60",
      "bash /tmp/seed_consul.sh",
      "sleep 30",
      "sudo systemctl restart consul"
    ]
  }
}

resource "google_compute_address" "servers-west" {
  count  = "${var.servers_count}"
  name   = "server-east-ipv4-address-${count.index + 1}"
  region = "${var.google_region_2}"
}

resource "cloudflare_record" "servers-west-google" {
  count  = "${var.servers_count}"
  domain = "${var.cf_domain}"
  name   = "server-west-google-${count.index + 1}.${var.cf_domain}"
  value  = "${google_compute_instance.servers-west.*.network_interface.0.access_config.0.nat_ip[count.index]}"
  type   = "A"
}

resource "google_compute_instance" "servers-west" {
  provider     = "google.west"
  count        = "${var.servers_count}"
  name         = "server-west-google-${count.index + 1}"
  hostname     = "server-west-google-${count.index + 1}.${var.cf_domain}"
  machine_type = "${var.google_server_machine_type}"
  zone         = "${data.google_compute_zones.west-azs.names[count.index]}"

  tags = [
    "consul-server",
    "consul-west-gcp"
  ]

  boot_disk {
    initialize_params {
      image = "ubuntu-1804-lts"
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.west-subnet.self_link}"

    access_config {
      nat_ip = "${element(google_compute_address.servers-west.*.address, count.index)}"
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
    #source      = "../files/gce-server-west.hcl"
    content     = "${data.template_file.gce-server-west.rendered}"
    destination = "/tmp/server.hcl"
  }

  #provisioner "file" {
  #  source      = "../files/consul.zip"
  #  destination = "/tmp/consul.zip"
  #}

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
    source      = "../files/seed_consul.sh"
    destination = "/tmp/seed_consul.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "${var.install_consul}",
      "${var.install_envconsul}",
      "${local.copy_cert_and_key}",
      "${var.set_consul_server_conf}",
      "${var.change_adver_addr_google}",
      "sudo systemctl restart consul",
      "${var.use_dnsmasq}",
      "sleep 60",
      "bash /tmp/seed_consul.sh",
      "sleep 60",
      "sudo systemctl restart consul"
    ]
  }
}

## Azure

resource "azurerm_network_interface" "servers-east-nic" {
  count                     = "${var.servers_count}"
  name                      = "servers-east-NIC-${count.index + 1}"
  location                  = "${azurerm_resource_group.east-rg.location}"
  resource_group_name       = "${azurerm_resource_group.east-rg.name}"
  network_security_group_id = "${azurerm_network_security_group.east-sg.id}"

  ip_configuration {
    name                          = "servers-east-NicConfiguration-${count.index}"
    subnet_id                     = "${azurerm_subnet.east-subnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${element(azurerm_public_ip.servers-east-publicip.*.id, count.index)}"
  }

  tags = {
    ehron-autojoin  = "${var.azure_east_dc}"
    ehron-server-aj = "consul-server"
    owner           = "ehron"
  }
}

resource "azurerm_public_ip" "servers-east-publicip" {
  count               = "${var.servers_count}"
  name                = "servers-east-publicip-${count.index  + 1}"
  location            = "${azurerm_resource_group.east-rg.location}"
  resource_group_name = "${azurerm_resource_group.east-rg.name}"
  allocation_method   = "Static"

  tags = {
    owner = "ehron"
  }
}

resource "cloudflare_record" "servers-east-azure" {
  count  = "${var.servers_count}"
  domain = "${var.cf_domain}"
  name   = "server-east-azure-${count.index + 1}.${var.cf_domain}"
  value  = "${azurerm_public_ip.servers-east-publicip.*.ip_address[count.index]}"
  type   = "A"
}

resource "azurerm_virtual_machine" "servers-east" {
  count                 = "${var.servers_count}"
  name                  = "server-east-azure-${count.index + 1}"
  location              = "${azurerm_resource_group.east-rg.location}"
  resource_group_name   = "${azurerm_resource_group.east-rg.name}"
  network_interface_ids = ["${element(azurerm_network_interface.servers-east-nic.*.id, count.index)}"]
  vm_size               = "${var.azure_server_machine_type}"

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
    name              = "servers-east-disk-${count.index + 1}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "server-east-azure-${count.index + 1}.${var.cf_domain}"
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

  tags = {
    ehron-autojoin  = "${var.azure_east_dc}"
    ehron-server-aj = "consul-server"
    owner           = "ehron"
  }

  connection {
    user     = "ehron"
    password = "${var.host_pw}"
    #private_key = "${file(var.ssh_private_key_path)}"
    agent = false
    type  = "ssh"
    host  = "${element(azurerm_public_ip.servers-east-publicip.*.ip_address, count.index)}"
  }

  provisioner "file" {
    content     = "${data.template_file.azure-server-east.rendered}"
    destination = "/tmp/server.hcl"
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
    source      = "../files/seed_consul.sh"
    destination = "/tmp/seed_consul.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "${var.install_consul}",
      "${var.install_envconsul}",
      "${local.copy_cert_and_key}",
      "${var.set_consul_server_conf}",
      "${var.change_adver_addr_azure}",
      "sudo systemctl restart consul",
      "${var.use_dnsmasq}",
      "sleep 60",
      "bash /tmp/seed_consul.sh",
      "sleep 60",
      "sudo systemctl restart consul"
    ]
  }
}

resource "azurerm_network_interface" "servers-west-nic" {
  count                     = "${var.servers_count}"
  name                      = "servers-west-NIC-${count.index + 1}"
  location                  = "${azurerm_resource_group.west-rg.location}"
  resource_group_name       = "${azurerm_resource_group.west-rg.name}"
  network_security_group_id = "${azurerm_network_security_group.west-sg.id}"

  ip_configuration {
    name                          = "servers-west-NicConfiguration-${count.index + 1}"
    subnet_id                     = "${azurerm_subnet.west-subnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${element(azurerm_public_ip.servers-west-publicip.*.id, count.index)}"
  }

  tags = {
    ehron-autojoin  = "${var.azure_west_dc}"
    ehron-server-aj = "consul-server"
    owner           = "ehron"
  }
}

resource "azurerm_public_ip" "servers-west-publicip" {
  count               = "${var.servers_count}"
  name                = "servers-west-publicip-${count.index + 1}"
  location            = "${azurerm_resource_group.west-rg.location}"
  resource_group_name = "${azurerm_resource_group.west-rg.name}"
  allocation_method   = "Static"

  tags = {
    owner = "ehron"
  }
}

resource "cloudflare_record" "servers-west-azure" {
  count  = "${var.servers_count}"
  domain = "${var.cf_domain}"
  name   = "server-west-azure-${count.index + 1}.${var.cf_domain}"
  value  = "${azurerm_public_ip.servers-west-publicip.*.ip_address[count.index]}"
  type   = "A"
}

resource "azurerm_virtual_machine" "servers-west" {
  count                 = "${var.servers_count}"
  name                  = "server-west-azure-${count.index + 1}"
  location              = "${azurerm_resource_group.west-rg.location}"
  resource_group_name   = "${azurerm_resource_group.west-rg.name}"
  network_interface_ids = ["${element(azurerm_network_interface.servers-west-nic.*.id, count.index)}"]
  vm_size               = "${var.azure_server_machine_type}"

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
    name              = "servers-west-disk-${count.index + 1}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "server-west-azure-${count.index + 1}.${var.cf_domain}"
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

  tags = {
    ehron-autojoin  = "${var.azure_west_dc}"
    ehron-server-aj = "consul-server"
    owner           = "ehron"
  }

  connection {
    user     = "ehron"
    password = "${var.host_pw}"
    #private_key = "${file(var.ssh_private_key_path)}"
    agent = false
    type  = "ssh"
    host  = "${element(azurerm_public_ip.servers-west-publicip.*.ip_address, count.index)}"
  }

  provisioner "file" {
    content     = "${data.template_file.azure-server-west.rendered}"
    destination = "/tmp/server.hcl"
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
    source      = "../files/seed_consul.sh"
    destination = "/tmp/seed_consul.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "${var.install_consul}",
      "${var.install_envconsul}",
      "${local.copy_cert_and_key}",
      "${var.set_consul_server_conf}",
      "${var.change_adver_addr_azure}",
      "sudo systemctl restart consul",
      "${var.use_dnsmasq}",
      "sleep 60",
      "bash /tmp/seed_consul.sh",
      "sleep 60",
      "sudo systemctl restart consul"
    ]
  }
} 