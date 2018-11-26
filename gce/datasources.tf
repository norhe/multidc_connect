data "google_compute_network" "east-network" {
  name     = "default"
  provider = "google.east"
}

data "google_compute_zones" "east-azs" {
  provider = "google.east"
}

data "google_compute_zones" "west-azs" {
  provider = "google.west"
}
