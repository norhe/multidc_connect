resource "google_compute_instance" "servers-east" {
  provider     = "google.east"
  count        = "${var.servers_count}"
  name         = "server-east-${count.index + 1}"
  machine_type = "${var.server_machine_type}"
  zone         = "${data.google_compute_zones.east-azs.names[count.index]}"

  tags = [
    "consul-server-east",
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
    private_key = "${file(var.ssh_private_key_path)}" 
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
  
  provisioner "file" {
    source = "${var.aws_credentials_path}"
    destination = "/tmp/credentials"
  }

  provisioner "file" {
    source      = "../files/seed_consul.sh"
    destination = "/tmp/seed_consul.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 30",
      "DEBIAN_FRONTEND=noninteractive sudo apt-get update",
      "DEBIAN_FRONTEND=noninteractive sudo apt-get install -y python3-pip",
      "pip3 install botocore boto3 ",
      "sudo mkdir ~/.aws && sudo cp -r /tmp/credentials ~/.aws/credentials",
      "git clone https://github.com/norhe/hashinstaller.git",
      #"sudo python3 hashinstaller/install.py -p consul -al /tmp/consul.zip",
      #"echo 'AWS_ACCESS_KEY_ID=${var.aws_key_id} AWS_SECRET_ACCESS_KEY=${var.aws_key} sudo -E python3 hashinstaller/install.py -p consul -loc 's3://hc-enterprise-binaries' -ie True'",
      "sudo -E python3 hashinstaller/install.py -p consul -loc 's3://hc-enterprise-binaries' -ie True",
      "sudo rm -rf ~/.aws",
      "sleep 30",
      "sudo rm -rf /etc/consul/*",
      "sudo mv /tmp/server.hcl /etc/consul/server.hcl",
      "sudo systemctl restart consul",
      "sudo bash /tmp/use_dnsmasq.sh",
      "sudo mv /tmp/dnsmasq.conf /etc/dnsmasq.conf",
      "sudo systemctl restart dnsmasq",
      "sleep 45",
      "bash /tmp/seed_consul.sh"
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
    "consul-server-west",
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
    private_key = "${file(var.ssh_private_key_path)}" 
  }
  
  provisioner "file" {
    source      = "../files/gce-server-west.hcl"
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
    source = "${var.aws_credentials_path}"
    destination = "/tmp/credentials"
  }

  provisioner "file" {
    source      = "../files/seed_consul.sh"
    destination = "/tmp/seed_consul.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 30",
      "DEBIAN_FRONTEND=noninteractive sudo apt-get update",
      "DEBIAN_FRONTEND=noninteractive sudo apt-get install -y python3-pip",
      "pip3 install botocore boto3 ",
      "git clone https://github.com/norhe/hashinstaller.git",
      #"sudo python3 hashinstaller/install.py -p consul -al /tmp/consul.zip",
      "sudo mkdir ~/.aws && sudo cp -r /tmp/credentials ~/.aws/credentials",
      "sudo python3 hashinstaller/install.py -p consul -loc 's3://hc-enterprise-binaries' -ie True",
      "sudo rm -rf ~/.aws",
      "sudo rm -rf /etc/consul/*",
      "sudo mv /tmp/server.hcl /etc/consul/server.hcl",
      "sudo systemctl restart consul",
      "sudo bash /tmp/use_dnsmasq.sh",
      "sudo mv /tmp/dnsmasq.conf /etc/dnsmasq.conf",
      "sudo systemctl restart dnsmasq",
      "sleep 60",
      "consul join -wan [${join(" ", google_compute_instance.servers-east.*.network_interface.0.access_config.0.assigned_nat_ip)}",
      "sleep 60",
      "bash /tmp/seed_consul.sh",
      "sleep 60",
      "sudo systemctl restart consul",
     ]
  }
}