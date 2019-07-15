resource "google_compute_instance" "listings-east" {
  provider     = "google.east"
  count        = "${var.listings_count}"
  name         = "listing-east-${count.index + 1}"
  machine_type = "${var.client_machine_type}"
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
    network = "${data.google_compute_network.east-network.self_link}"

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
    user  = "ehron"
    private_key = "${file(var.ssh_private_key_path)}"
    type = "ssh"
    host = "${self.network_interface.0.access_config.0.nat_ip}"
  }
  
  provisioner "file" {
    source      = "../files/gce-client-east.hcl"
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
    source = "${var.aws_credentials_path}"
    destination = "/tmp/credentials"
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
      "sudo python3 hashinstaller/install.py -p envconsul -v 0.7.3",
      "sleep 30",
      "sudo rm -rf /etc/consul/*",
      "sudo mv /tmp/client.hcl /etc/consul/client.hcl",
      "sudo mv /tmp/listing_pq.hcl /etc/consul/listing_pq.hcl",
      "sudo mv /tmp/listing_svc.hcl /etc/consul/listing_svc.hcl.disabled",
      "sudo systemctl restart consul",
      "sudo bash /tmp/use_dnsmasq.sh",
      "sudo mv /tmp/dnsmasq.conf /etc/dnsmasq.conf",
      "sudo systemctl restart dnsmasq",
      "git clone https://github.com/norhe/listing-service.git",
      "sudo bash listing-service/install/install.sh",
      "sudo bash /tmp/install_envoy.sh listing",
      #"sudo systemctl disable envoy_proxy.service",
      #"sudo systemctl stop envoy_proxy.service", # bug with envoy and prepared queries so disable for now
      #"sudo bash /tmp/install_consul_proxy.sh listing",
      "sleep 120",
      "sudo systemctl restart consul",
      "sleep 30",
      "sudo systemctl restart consul_proxy"
     ]
  }
}

resource "google_compute_instance" "listings-west" {
  provider     = "google.west"
  count        = "${var.listings_count}"
  name         = "listing-west-${count.index + 1}"
  machine_type = "${var.client_machine_type}"
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
    network = "${data.google_compute_network.east-network.self_link}"

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
    user  = "ehron"
    private_key = "${file(var.ssh_private_key_path)}" 
    type = "ssh"
    host = "${self.network_interface.0.access_config.0.nat_ip}"
  }
  
  provisioner "file" {
    source      = "../files/gce-client-west.hcl"
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
    source = "${var.aws_credentials_path}"
    destination = "/tmp/credentials"
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
      "sudo python3 hashinstaller/install.py -p envconsul -v 0.7.3",
      "sleep 30",
      "sudo rm -rf /etc/consul/*",
      "sudo mv /tmp/client.hcl /etc/consul/client.hcl",
      "sudo mv /tmp/listing_pq.hcl /etc/consul/listing_pq.hcl",
      "sudo mv /tmp/listing_svc.hcl /etc/consul/listing_svc.hcl.disabled",
      "sudo systemctl restart consul",
      "sudo bash /tmp/use_dnsmasq.sh",
      "sudo mv /tmp/dnsmasq.conf /etc/dnsmasq.conf",
      "sudo systemctl restart dnsmasq",
      "git clone https://github.com/norhe/listing-service.git",
      "sudo bash listing-service/install/install.sh",
      "sudo bash /tmp/install_envoy.sh listing",
      #"sudo systemctl disable envoy_proxy.service",
      #"sudo systemctl stop envoy_proxy.service", # bug with envoy and prepared queries so disable for now
      #"sudo bash /tmp/install_consul_proxy.sh listing",
      "sleep 120",
      "sudo systemctl restart consul",
      "sleep 30",
      "sudo systemctl restart consul_proxy"
     ]
  }
}