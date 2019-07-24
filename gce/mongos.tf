resource "google_compute_instance" "mongodb-east" {
  provider     = "google.east"
  count        = "${var.mongos_count}"
  name         = "mongodb-east-${count.index + 1}"
  machine_type = "${var.client_machine_type}"
  zone         = "${data.google_compute_zones.east-azs.names[count.index]}"

  tags = [
    "consul-east-dc"
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
    user  = "ehron"
    private_key = "${file(var.ssh_private_key_path)}"
    type = "ssh"
    host = "${self.network_interface.0.access_config.0.nat_ip}" 
  }
  
  provisioner "file" {
    #source      = "../files/gce-client-east.hcl"
    content     = "${data.template_file.gce-client-east.rendered}"
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

  provisioner "file" {
    source      = "../files/install_consul_proxy.sh"
    destination = "/tmp/install_consul_proxy.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "${var.install_consul}",
      "${var.set_consul_client_conf}",
      "${var.set_consul_mongo_conf}",
      "${var.install_envconsul}",
      "${var.use_dnsmasq}",
      "${var.install_mongodb_and_proxy}"
      #"${var.sync_envoy}"
    ]
  }
}


resource "google_compute_instance" "mongodb-west" {
  provider     = "google.west"
  count        = "${var.mongos_count}"
  name         = "mongodb-west-${count.index + 1}"
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
    user  = "ehron"
    private_key = "${file(var.ssh_private_key_path)}"
    type = "ssh"
    host = "${self.network_interface.0.access_config.0.nat_ip}"
  }
  
  provisioner "file" {
    #source      = "../files/gce-client-west.hcl"
    content     = "${data.template_file.gce-client-west.rendered}"
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

  provisioner "file" {
    source      = "../files/install_consul_proxy.sh"
    destination = "/tmp/install_consul_proxy.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "${var.install_consul}",
      "${var.set_consul_client_conf}",
      "${var.set_consul_mongo_conf}",
      "${var.install_envconsul}",
      "${var.use_dnsmasq}",
      "${var.install_mongodb_and_proxy}"
      #"${var.sync_envoy}"
     ]
  }
}