resource "google_compute_instance" "servers-east" {
  provider     = "google.east"
  count        = "${var.servers_count}"
  name         = "server-east-${count.index + 1}"
  machine_type = "${var.server_machine_type}"
  zone         = "${data.google_compute_zones.east-azs.names[count.index]}"

  tags = [
    "consul-server",
  ]

  boot_disk {
    initialize_params {
      image = "ubuntu-1804-lts"
    }
  }

  network_interface {
    network = "${data.google_compute_network.east-network.self_link}"

    access_config {
      // ephemeral public IP
    }
  }

  metadata {
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
    user  = "ehron"
    private_key = "${file(var.key_path)}" # encrypted keys not supported, don't use
  }
  
  provisioner "file" {
    source      = "../files/gce-server-east.hcl"
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
  
  provisioner "remote-exec" {
    inline = [
      "sleep 30",
      "git clone https://github.com/norhe/hashinstaller.git",
      #"sudo python3 hashinstaller/install.py -p consul -al /tmp/consul.zip",
      "AWS_ACCESS_KEY_ID=${var.aws_key_id} AWS_SECRET_ACCESS_KEY={$var.aws_key} sudo -E python3 install.py -p consul -loc 's3://hc-enterprise-binaries' -ie True",
      "sudo mv /tmp/server.hcl /etc/consul/server.hcl",
      "sudo systemctl restart consul",
      "sudo mv /tmp/dnsmasq.conf /etc/dnsmasq.conf",
      "sudo bash /tmp/use_dnsmasq.sh"
     ]
  }
}

resource "google_compute_instance" "servers-west" {
  provider     = "google.west"
  count        = "${var.servers_count}"
  name         = "server-west-${count.index + 1}"
  machine_type = "${var.server_machine_type}"
  zone         = "${data.google_compute_zones.west-azs.names[count.index]}"

  tags = [
    "consul-server",
  ]

  boot_disk {
    initialize_params {
      image = "ubuntu-1804-lts"
    }
  }

  network_interface {
    network = "${data.google_compute_network.east-network.self_link}"

    access_config {
      // ephemeral public IP
    }
  }

  metadata {
    sshKeys = "${var.ssh_user}:${var.ssh_public}"
  }

  lifecycle {
    create_before_destroy = true
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/compute.readonly"]
  }

  allow_stopping_for_update = true

  connection {
    user  = "ehron"
    private_key = "${file(var.key_path)}" # encrypted keys not supported, don't use
  }
  
  provisioner "file" {
    source      = "../files/gce-server-east.hcl"
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
  
  provisioner "remote-exec" {
    inline = [
      "sleep 30",
      "git clone https://github.com/norhe/hashinstaller.git",
      #"sudo python3 hashinstaller/install.py -p consul -al /tmp/consul.zip",
      "AWS_ACCESS_KEY_ID=${var.aws_key_id} AWS_SECRET_ACCESS_KEY={$var.aws_key} sudo -E python3 install.py -p consul -loc 's3://hc-enterprise-binaries' -ie True",
      "sudo mv /tmp/server.hcl /etc/consul/server.hcl",
      "sudo systemctl restart consul",
      "sudo mv /tmp/dnsmasq.conf /etc/dnsmasq.conf",
      "sudo bash /tmp/use_dnsmasq.sh"
     ]
  }
}