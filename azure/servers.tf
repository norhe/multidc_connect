
resource "azurerm_network_interface" "servers-east-nic" {
  count                     = "${var.servers_count}"
  name                      = "servers-east-NIC-${count.index}"
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
    ehron-autojoin  = "${var.east_dc}"
    ehron-server-aj = "consul-server"
    owner           = "ehron"
  }
}

resource "azurerm_public_ip" "servers-east-publicip" {
  count               = "${var.servers_count}"
  name                = "servers-east-publicip-${count.index}"
  location            = "${azurerm_resource_group.east-rg.location}"
  resource_group_name = "${azurerm_resource_group.east-rg.name}"
  allocation_method   = "Static"

  tags = {
    owner = "ehron"
  }
}

resource "azurerm_virtual_machine" "servers-east" {
  count                 = "${var.servers_count}"
  name                  = "server-east-${count.index}"
  location              = "${azurerm_resource_group.east-rg.location}"
  resource_group_name   = "${azurerm_resource_group.east-rg.name}"
  network_interface_ids = ["${element(azurerm_network_interface.servers-east-nic.*.id, count.index)}"]
  vm_size               = "${var.server_machine_type}"

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
    name              = "servers-east-disk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "server-east-${count.index}"
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
    ehron-autojoin  = "${var.east_dc}"
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
      "${var.set_consul_server_conf}",
      "${var.use_dnsmasq}",
      "sleep 60",
      "bash /tmp/seed_consul.sh",
      "sleep 60",
      "sudo systemctl restart consul"
    ]
  }
}

#data "azurerm_public_ip" "servers-east" {
#  count               = "${var.servers_count}"
#  name                = "${element(azurerm_public_ip.servers-east-publicip, count.index)}"
#  resource_group_name = "${azurerm_virtual_machine.servers-east.resource_group_name}"
#}



resource "azurerm_network_interface" "servers-west-nic" {
  count                     = "${var.servers_count}"
  name                      = "servers-west-NIC-${count.index}"
  location                  = "${azurerm_resource_group.west-rg.location}"
  resource_group_name       = "${azurerm_resource_group.west-rg.name}"
  network_security_group_id = "${azurerm_network_security_group.west-sg.id}"

  ip_configuration {
    name                          = "servers-west-NicConfiguration-${count.index}"
    subnet_id                     = "${azurerm_subnet.west-subnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${element(azurerm_public_ip.servers-west-publicip.*.id, count.index)}"
  }

  tags = {
    ehron-autojoin  = "${var.west_dc}"
    ehron-server-aj = "consul-server"
    owner           = "ehron"
  }
}

resource "azurerm_public_ip" "servers-west-publicip" {
  count               = "${var.servers_count}"
  name                = "servers-west-publicip-${count.index}"
  location            = "${azurerm_resource_group.west-rg.location}"
  resource_group_name = "${azurerm_resource_group.west-rg.name}"
  allocation_method   = "Static"

  tags = {
    owner = "ehron"
  }
}

resource "azurerm_virtual_machine" "servers-west" {
  count                 = "${var.servers_count}"
  name                  = "server-west-${count.index}"
  location              = "${azurerm_resource_group.west-rg.location}"
  resource_group_name   = "${azurerm_resource_group.west-rg.name}"
  network_interface_ids = ["${element(azurerm_network_interface.servers-west-nic.*.id, count.index)}"]
  vm_size               = "${var.server_machine_type}"

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
    name              = "servers-west-disk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "server-west-${count.index}"
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
    ehron-autojoin  = "${var.west_dc}"
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
      "${var.set_consul_server_conf}",
      "${var.use_dnsmasq}",
      "sleep 60",
      "bash /tmp/seed_consul.sh",
      "sleep 60",
      "sudo systemctl restart consul"
    ]
  }
} 