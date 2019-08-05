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

variable "listings_count" {
  description = "How many listings servers to create in each region"
  default     = "1"
}

variable "products_count" {
  description = "How many listings servers to create in each region"
  default     = "1"
}

variable "mongos_count" {
  description = "How many listings servers to create in each region"
  default     = "1"
}

variable "web-clients_count" {
  description = "How many listings servers to create in each region"
  default     = "1"
}

variable "install_consul" {
  description = "The command to pass to the provisioner to install Hashicorp software"
  default     = <<-COMMAND
      sleep 30
      cp /tmp/terraform_* ~/terrascript.sh
      DEBIAN_FRONTEND=noninteractive sudo apt-get update
      DEBIAN_FRONTEND=noninteractive sudo apt-get install -y python3-pip
      pip3 install botocore boto3
      sudo mkdir ~/.aws && sudo cp -r /tmp/credentials ~/.aws/credentials
      git clone https://github.com/norhe/hashinstaller.git
      #sudo -E python3 hashinstaller/install.py -p consul -loc 's3://hc-enterprise-binaries' -ie True
      sudo -E python3 hashinstaller/install.py -p consul -v 1.6.0 -loc 's3://hc-enterprise-binaries' -ie True -of 'consul-enterprise_1.6.0+prem-beta2_linux_amd64.zip'
      sudo rm -rf ~/.aws
      rm /tmp/credentials
      sleep 15
  COMMAND
}

variable "install_envconsul" {
  description = "The command to pass to the provisioner to install Hashicorp software"
  default = <<-COMMAND
    sudo python3 hashinstaller/install.py -p envconsul -v 0.8.0
    sleep 3
  COMMAND
}

variable "set_consul_server_conf" {
  description = "Command to set up Consul servers with the proper config"
  default     = <<-COMMAND
      sudo rm -rf /etc/consul/*
      sudo mv /tmp/server.hcl /etc/consul/server.hcl
      sudo systemctl restart consul
      sleep 60
  COMMAND
}

# /**/
variable "set_consul_client_conf" {
  description = "Command to set up Consul servers with the proper config"
  default = <<-COMMAND
      sudo rm -rf /etc/consul/*
      sudo mv /tmp/client.hcl /etc/consul/client.hcl
      sudo systemctl restart consul
      sleep 60
  COMMAND
}
# /**/
variable "set_consul_listing_conf" {
  description = "Command to set up Consul agents with the proper config for listing service"
  default     = <<-COMMAND
      sudo mv /tmp/listing_pq.hcl /etc/consul/listing_pq.hcl
      sudo mv /tmp/listing_svc.hcl /etc/consul/listing_svc.hcl.disabled
      consul reload
  COMMAND
}

variable "set_consul_product_conf" {
  description = "Command to set up Consul agents with the proper config for product service"
  default = <<-COMMAND
      sudo mv /tmp/product_pq.hcl /etc/consul/product_pq.hcl
      sudo mv /tmp/product_svc.hcl /etc/consul/product_svc.hcl.disabled
      consul reload
  COMMAND
}

variable "set_consul_web_client_conf" {
  description = "Command to set up Consul agents with the proper config for the web_client service"
  default     = <<-COMMAND
      sudo mv /tmp/web_client_pq.hcl /etc/consul/web_client_pq.hcl
      sudo mv /tmp/web_client_svc.hcl /etc/consul/web_client_svc.hcl.disabled
      consul reload
  COMMAND
}

variable "set_consul_mongo_conf" {
  description = "Command to set up Consul agents with the proper config for mongo service"
  default = <<-COMMAND
      sudo mv /tmp/mongodb.hcl /etc/consul/mongodb.hcl
      consul reload
  COMMAND
}

variable "sync_envoy" {
  description = "Push proxy config to Envoy"
  default     = <<-COMMAND
      sleep 15 # give time for the prepared queries to be created
      echo 'Restarting Consul' && sudo systemctl restart consul
  COMMAND
}

variable "use_dnsmasq" {
  default = <<-COMMAND
    sudo bash /tmp/use_dnsmasq.sh
    sudo mv /tmp/dnsmasq.conf /etc/dnsmasq.conf
    sudo systemctl restart dnsmasq
  COMMAND
}

variable "install_web_client_and_proxy" {
  default = <<-COMMAND
      git clone https://github.com/norhe/simple-client.git
      sudo bash simple-client/install/install.sh
      sudo bash /tmp/install_envoy.sh web_client
      # test consul proxy instead of Envoy
      sudo systemctl disable envoy_proxy
      sudo systemctl stop envoy_proxy # bug with envoy and prepared queries so disable for now
      sudo bash /tmp/install_consul_proxy.sh web_client
      sleep 120 # give time for the prepared queries to be created
  COMMAND
}

variable "install_mongodb_and_proxy" {
  default = <<-COMMAND
      sudo bash /tmp/install_mongodb.sh
      sudo bash /tmp/install_envoy.sh mongodb
      # test consul proxy instead of Envoy
      sudo systemctl disable envoy_proxy
      sudo systemctl stop envoy_proxy # bug with envoy and prepared queries so disable for now
      sudo bash /tmp/install_consul_proxy.sh mongodb
      sleep 120 # give time for the prepared queries to be created
  COMMAND
}

variable "install_product_and_proxy" {
  default = <<-COMMAND
      git clone https://github.com/norhe/product-service.git
      sudo bash product-service/install/install.sh
      sudo bash /tmp/install_envoy.sh product
      # test consul proxy instead of Envoy
      sudo systemctl disable envoy_proxy
      sudo systemctl stop envoy_proxy # bug with envoy and prepared queries so disable for now
      sudo bash /tmp/install_consul_proxy.sh product
      sleep 120 # give time for the prepared queries to be created
  COMMAND
}

variable "install_listing_and_proxy" {
  default = <<-COMMAND
      git clone https://github.com/norhe/listing-service.git
      sudo bash listing-service/install/install.sh
      sudo bash /tmp/install_envoy.sh listing
      # test consul proxy instead of Envoy
      sudo systemctl disable envoy_proxy
      sudo systemctl stop envoy_proxy # bug with envoy and prepared queries so disable for now
      sudo bash /tmp/install_consul_proxy.sh listing
      sleep 120 # give time for the prepared queries to be created
  COMMAND
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