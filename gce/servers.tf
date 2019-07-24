resource "google_compute_instance" "servers-east" {
  provider     = "google.east"
  count        = "${var.servers_count}"
  name         = "server-east-${count.index + 1}"
  machine_type = "${var.server_machine_type}"
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
      "${var.set_consul_server_conf}",
      "${var.use_dnsmasq}",
      "sleep 60",
      "bash /tmp/seed_consul.sh",
      "sleep 60",
      "sudo systemctl restart consul"
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
      "${var.set_consul_server_conf}",
      "${var.use_dnsmasq}",
      "sleep 60",
      "bash /tmp/seed_consul.sh",
      "sleep 60",
      "sudo systemctl restart consul"
    ]
  }
}