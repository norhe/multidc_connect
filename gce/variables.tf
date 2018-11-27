# Required
variable "ssh_public_key" {
  description = "Contents of the public key"
}

variable "ssh_private_key_path" {
  description = "Private key to use for provisioning"
}

variable "aws_credentials_path" {
  description = "Private key to use for provisioning"
}

variable "aws_key" {
  description = "The key data to use when downloading enterprise tools"
}

variable "aws_key_id" {
  description = "The key id to use when downloading enterprise tools"
}

variable "ssh_user" {
  description = "Username of ssh user created with the ssh_key_data key"
}

# Optional
variable "server_machine_type" {
  description = "The machine type (size) to deploy"
  default     = "n1-standard-1"
}

variable "region_1" {
  description = "Region into which to deploy"
  default     = "us-east1"
}

variable "region_2" {
  description = "Region into which to deploy"
  default     = "us-west1"
}


variable "client_machine_type" {
  description = "The machine type (size) to deploy"
  default     = "g1-small"
}

variable "servers_count" {
  description = "How many servers to create in each region"
  default     = "3"
}

output "server_ips_east" {
  value = ["${google_compute_instance.servers-east.*.network_interface.0.access_config.0.assigned_nat_ip}"]
}

output "server_ips_west" {
  value = ["${google_compute_instance.servers-west.*.network_interface.0.access_config.0.assigned_nat_ip}"]
}

#output "vault_server_ips" {
#  value = ["${google_compute_instance.vault-servers-east.*.network_interface.0.access_config.0.assigned_nat_ip}"]
#}