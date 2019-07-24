resource "google_compute_network" "app_network" {
  name = "app-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "east-subnet" {
  name   = "east-subnet"
  region = "${var.region_1}"
  ip_cidr_range = "10.3.0.0/16"
  network = "${google_compute_network.app_network.self_link}"
}

resource "google_compute_subnetwork" "west-subnet" {
  name   = "west-subnet"
  region = "${var.region_2}"
  ip_cidr_range = "10.4.0.0/16"
  network = "${google_compute_network.app_network.self_link}"
}


# Allow SSH for iperf testing.
resource "google_compute_firewall" "gcp-allow-traffic" {
  name    = "${google_compute_network.app_network.name}-gcp-allow-traffic"
  network = "${google_compute_network.app_network.name}"

  allow {
    protocol = "tcp"
    ports = ["22", "80", "443", "8080"]
  }

  source_ranges = [
    "0.0.0.0/0"
  ]
}

resource "google_compute_firewall" "allow-consul" {
  name     = "hc-traffic"
  network  = "${google_compute_network.app_network.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["8200", "8300", "8301", "8302", "8500"]
  }
}

resource "google_compute_firewall" "allow-consul-wan-east" {
  name     = "consul-wan-east-1"
  network  = "${google_compute_network.app_network.self_link}"

  allow {
    protocol = "udp"
    ports    = ["8301", "8302"]
  }
}

resource "google_compute_firewall" "allow-internal" {
  name     = "http-east-1"
  network  = "${google_compute_network.app_network.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = [
    "10.0.0.0/8"
  ]
}


## VPN

