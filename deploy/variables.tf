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
  default     = "Don't commit me to src control!"
}

variable "aws_key_id" {
  description = "The key id to use when downloading enterprise tools"
  default     = "Don't commit me to src control!"
}

variable "ssh_user" {
  description = "Username of ssh user created with the ssh_key_data key"
}

variable "cf_email" {
  description = "Email address for cloudflare DNS"
}

variable "cf_token_path" {
  description = "Token for cloudflare DNS"
}

variable "cf_token" {
  description = "Token for cloudflare DNS"
}

variable "cf_domain" {
  description = "Domain for DNS"
  default     = "example.com"
}

variable "gossip_encrypt_key" {
  default = "null"
}

# RPC TLS
variable "ca_file" {
  default = "null"
}

variable "cert_file" {
  default = "null"
}

variable "cert_file_contents" {
  default = "null"
}

variable "key_file" {
  default = "null"
}

variable "key_file_contents" {
  default = "null"
}

# Optional

# See https://www.consul.io/docs/agent/cloud-auto-join.html#microsoft-azure
# Create a read-only SP: az ad sp create-for-rbac --role="Reader" --scopes="/subscriptions/[YOUR_SUBSCRIPTION_ID]"
variable "aj_tenant_id" {
  description = "Tenant ID to be used in auto-join operations"
  default     = "None"
}

variable "aj_client_id" {
  description = "Client ID to be used in auto-join operations"
  default     = "None"
}

variable "aj_subscription_id" {
  description = "Subscription ID to be used in auto-join operations"
  default     = "None"
}

variable "aj_secret_access_key" {
  description = "Secret access key to be used in auto-join operations"
  default     = "None"
}

variable "aj_tag_name" {
  description = "Auto-join tag"
  default     = "autojoin"
}

variable "azure_east_dc" {
  default = "consul-east-azure"
}

variable "azure_west_dc" {
  default = "consul-west-azure"
}

variable "host_pw" {
  default = "Password1234!"
}

# Optional
variable "azure_server_machine_type" {
  description = "The machine type (size) to deploy"
  default     = "Standard_A4_v2"
}

variable "azure_region_1" {
  description = "Region into which to deploy"
  default     = "us-east1"
}

variable "azure_region_2" {
  description = "Region into which to deploy"
  default     = "us-west1"
}


variable "azure_client_machine_type" {
  description = "The machine type (size) to deploy"
  default     = "Standard_A1_v2"
}


variable "google_server_machine_type" {
  description = "The machine type (size) to deploy"
  default     = "n1-standard-1"
}

variable "google_region_1" {
  description = "Region into which to deploy"
  default     = "us-east1"
}

variable "google_region_2" {
  description = "Region into which to deploy"
  default     = "us-west1"
}


variable "google_client_machine_type" {
  description = "The machine type (size) to deploy"
  default     = "g1-small"
}

variable "servers_count" {
  description = "How many servers to create in each region"
  default     = "3"
}

variable "gateways_count" {
  description = "How many gateways to create in each region"
  default     = "1"
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
      cp /tmp/terraform_* ~/terrascript.sh # debugging purposes
      # use locally built consul binary due to bug
      /*DEBIAN_FRONTEND=noninteractive sudo apt-get update
      DEBIAN_FRONTEND=noninteractive sudo apt-get install -y python3-pip jq
      pip3 install botocore boto3
      sudo mkdir ~/.aws && sudo cp -r /tmp/credentials ~/.aws/credentials
      git clone https://github.com/norhe/hashinstaller.git
      #sudo -E python3 hashinstaller/install.py -p consul -loc 's3://hc-enterprise-binaries' -ie True
      sudo -E python3 hashinstaller/install.py -p consul -v 1.6.0 -loc 's3://hc-enterprise-binaries' -ie True -of 'consul-enterprise_1.6.0+prem-beta3_linux_amd64.zip'
      sudo rm -rf ~/.aws
      rm /tmp/credentials*/
      sudo -E python3 hashinstaller/install.py -p consul -al /tmp/consul.zip
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

variable "install_gateway_proxy" {
  default = <<-COMMAND
      sudo bash /tmp/install_envoy.sh mesh-gateway
      # test consul proxy instead of Envoy
      sudo systemctl disable envoy_proxy
      sudo systemctl stop envoy_proxy 
      sudo bash /tmp/install_gateway.sh
      sleep 10
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

variable "change_adver_addr_azure" {
  default = <<-COMMAND
      echo "advertise_addr_wan = $(curl -H Metadata:true 'http://169.254.169.254/metadata/instance?api-version=2019-06-04' |jq .network.interface[0].ipv4.ipAddress[0].publicIpAddress)" | sudo tee /etc/consul/advertise_addr.hcl
      echo "translate_wan_addrs = true" | sudo tee -a /etc/consul/advertise_addr.hcl 
  COMMAND
}

variable "change_adver_addr_google" {
  default = <<-COMMAND
      echo "advertise_addr_wan = \"$(curl -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip)\"" | sudo tee /etc/consul/advertise_addr.hcl
      echo "translate_wan_addrs = true" | sudo tee -a /etc/consul/advertise_addr.hcl 
  COMMAND
}

variable "create_mesh_command_azure" {
  default = <<-COMMAND
      DC="$(curl http://127.0.0.1:8500/v1/catalog/node/$(hostname) | jq .Node.Datacenter)"
      EXT_ADDR=$(curl -H Metadata:true 'http://169.254.169.254/metadata/instance?api-version=2019-06-04' |jq .network.interface[0].ipv4.ipAddress[0].publicIpAddress)
      printf 'consul connect envoy -mesh-gateway -register \
          -service "gateway-%s" \
          -address "{{ GetPrivateIP }}:2000" \
          -wan-address "%s:3000"' $DC $EXT_ADDR | sudo tee /etc/consul/run_proxy.sh
  COMMAND
}

variable "create_mesh_command_google" {
  default = <<-COMMAND
      DC="$(curl http://127.0.0.1:8500/v1/catalog/node/$(hostname) | jq -r .Node.Datacenter)"
      EXT_ADDR=$(curl -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip)
      printf 'consul connect envoy -mesh-gateway -register \
          -service "gateway-%s" \
          -address "{{ GetPrivateIP }}:2000" \
          -wan-address "%s:3000"' $DC $EXT_ADDR | sudo tee /etc/consul/run_proxy.sh
  COMMAND
}

/*variable "copy_cert_and_key" {
  description = "Upload TLS cert and key"
  default     = <<-COMMAND
      echo "${var.cert_file_contents} | sudo tee ${var.cert_file}"
      echo "${var.key_file_contents} | sudo tee ${var.key_file}"
      sudo chown root:root ${var.key_file}
      sudo chmod 0600 ${var.key_file}
      echo "Uploaded cert and key to ${var.cert_file} and ${var.key_file}"
  COMMAND
}*/

variable "enable_central_service_config" {
  default = true
}

variable config_entries {
  default = <<-CONFIG
    {
      bootstrap = {
        kind = "proxy-defaults"
        name = "global"
        #config {
          #envoy_prometheus_bind_addr = "0.0.0.0:9102"
        #}
        MeshGateway = {
          Mode = "local"
        }
      }
    }
  CONFIG
}

/*output "server_ips_east" {
  #value = ["${google_compute_instance.servers-east.*.network_interface.0.access_config.0.assigned_nat_ip}"]
  value = google_compute_instance.servers-east[*].network_interface.0.access_config.0.assigned_nat_ip
}

output "server_ips_west" {
  value = ["${google_compute_instance.servers-west.*.network_interface.0.access_config.0.assigned_nat_ip}"]
}

#output "vault_server_ips" {
#  value = ["${google_compute_instance.vault-servers-east.*.network_interface.0.access_config.0.assigned_nat_ip}"]
#}*/

## locals
locals {
  copy_cert_and_key = <<-COMMAND
    /*echo \"${file(var.cert_file_contents)}\" | sudo tee ${var.cert_file}
    echo \"${file(var.key_file_contents)}\" | sudo tee ${var.key_file}
    sudo chown root:root ${var.key_file}
    sudo chmod 0600 ${var.key_file}
    echo "Uploaded cert and key to ${var.cert_file} and ${var.key_file}"*/
    echo "skipping key copy"
  COMMAND
}