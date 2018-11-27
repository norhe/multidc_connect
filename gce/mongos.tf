resource "google_compute_instance" "mongodb-east" {
  provider     = "google.east"
  count        = "${var.mongos_count}"
  name         = "mongodb-east-${count.index + 1}"
  machine_type = "${var.client_machine_type}"
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
    source      = "../files/gce-client-east.hcl"
    destination = "/tmp/client.hcl"
  }

  provisioner "file" {
    source      = "../files/services/mongodb.hcl"
    destination = "/tmp/mongodb.hcl"
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
    source = "${var.aws_credentials_path}"
    destination = "/tmp/credentials"
  }

  provisioner "file" {
    source      = "../files/install_mongodb.sh"
    destination = "/tmp/install_mongodb.sh"
  }

  provisioner "file" {
    source = "${var.aws_credentials_path}"
    destination = "/tmp/credentials"
  }

  provisioner "file" {
    source      = "../files/install_envoy.sh"
    destination = "/tmp/install_envoy.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 30",
      "DEBIAN_FRONTEND=noninteractive sudo apt-get update",
      "DEBIAN_FRONTEND=noninteractive sudo apt-get install -y python3-pip",
      "pip3 install botocore boto3 ",
      "sudo mkdir ~/.aws && sudo cp -r /tmp/credentials ~/.aws/credentials",
      "git clone https://github.com/norhe/hashinstaller.git",
      "sudo -E python3 hashinstaller/install.py -p consul -loc 's3://hc-enterprise-binaries' -ie True",
      "sudo rm -rf ~/.aws",
      "sleep 30",
      "sudo rm -rf /etc/consul/*",
      "sudo mv /tmp/client.hcl /etc/consul/client.hcl",
      "sudo mv /tmp/mongodb.hcl /etc/consul/mongodb.hcl",
      "sudo systemctl restart consul",
      "sudo bash /tmp/use_dnsmasq.sh",
      "sudo mv /tmp/dnsmasq.conf /etc/dnsmasq.conf",
      "sudo systemctl restart dnsmasq",
      "sudo bash /tmp/install_mongodb.sh",
      "sudo bash /tmp/install_envoy.sh mongodb"
     ]
  }
}