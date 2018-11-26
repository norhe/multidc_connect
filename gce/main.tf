provider "google" {
  region = "${var.region_1}"
  alias  = "east"
}

provider "google" {
  region = "${var.region_2}"
  alias  = "west"
}