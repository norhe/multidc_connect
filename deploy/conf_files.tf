locals {
  retry_list_values = "${join(", ", [ for i in range(var.servers_count): "\"server-west-azure-${i+1}.${var.cf_domain}\", \"server-east-azure-${i+1}.${var.cf_domain}\", \"server-east-google-${i+1}.${var.cf_domain}\", \"server-west-google-${i+1}.${var.cf_domain}\""] ) }"
}


## Google
data "template_file" "gce-client-east" {
  template = "${file("${path.module}/../files/consul-config-template.hcl")}"
  vars = {
    datacenter                    = "east-gcp"
    log_level                     = "DEBUG"
    retry_join                    = "\"provider=gce project_name=eq-env tag_value=consul-east-gcp\""
    is_server                     = false
    enable_central_service_config = true
    gossip_encrypt_key            = "${var.gossip_encrypt_key}"
    ca_file                       = "${var.ca_file}"
    cert_file                     = "${var.cert_file}"
    key_file                      = "${var.key_file}"
  }
}

data "template_file" "gce-client-west" {
  template = "${file("${path.module}/../files/consul-config-template.hcl")}"
  vars = {
    datacenter                    = "west-gcp"
    log_level                     = "DEBUG"
    retry_join                    = "\"provider=gce project_name=eq-env tag_value=consul-west-gcp\""
    is_server                     = false
    enable_central_service_config = true
    gossip_encrypt_key            = "${var.gossip_encrypt_key}"
    ca_file                       = "${var.ca_file}"
    cert_file                     = "${var.cert_file}"
    key_file                      = "${var.key_file}"
  }
}

data "template_file" "gce-server-west" {
  template = "${file("${path.module}/../files/consul-config-template.hcl")}"
  vars = {
    datacenter         = "west-gcp"
    log_level          = "DEBUG"
    retry_join         = "\"provider=gce project_name=eq-env tag_value=consul-west-gcp\""
    is_server          = true
    non_voting_server  = false
    retry_join_wan     = "${local.retry_list_values}"
    #retry_join_wan     = "\"provider=gce project_name=eq-env tag_value=consul-server\", \"provider=azure tag_name=ehron-server-aj tag_value=consul-server tenant_id=${var.aj_tenant_id} client_id=${var.aj_client_id} subscription_id=${var.aj_subscription_id} secret_access_key=${var.aj_secret_access_key} \""
    connect_enabled    = true
    primary_datacenter = "east-gcp"

    enable_central_service_config = "${var.enable_central_service_config}"
    config_entries                = "${var.config_entries}"
    gossip_encrypt_key            = "${var.gossip_encrypt_key}"
    ca_file                       = "${var.ca_file}"
    cert_file                     = "${var.cert_file}"
    key_file                      = "${var.key_file}"
  }
}

data "template_file" "gce-server-east" {
  template = "${file("${path.module}/../files/consul-config-template.hcl")}"
  vars = {
    datacenter         = "east-gcp"
    log_level          = "DEBUG"
    retry_join         = "\"provider=gce project_name=eq-env tag_value=consul-east-gcp\""
    is_server          = true
    non_voting_server  = false
    retry_join_wan         = "${local.retry_list_values}"
    #retry_join_wan     = "\"provider=gce project_name=eq-env tag_value=consul-server\", \"provider=azure tag_name=ehron-server-aj tag_value=consul-server tenant_id=${var.aj_tenant_id} client_id=${var.aj_client_id} subscription_id=${var.aj_subscription_id} secret_access_key=${var.aj_secret_access_key} \""
    connect_enabled    = true
    primary_datacenter = "east-gcp"
    gossip_encrypt_key = "${var.gossip_encrypt_key}"
    ca_file            = "${var.ca_file}"
    cert_file          = "${var.cert_file}"
    key_file           = "${var.key_file}"
  }
}

## Azure
data "template_file" "azure-client-east" {
  template = "${file("${path.module}/../files/consul-config-template.hcl")}"
  vars = {
    datacenter         = "east-azure"
    log_level          = "DEBUG"
    retry_join         = "\"provider=azure tag_name=${var.aj_tag_name} tag_value=${var.azure_east_dc} tenant_id=${var.aj_tenant_id} client_id=${var.aj_client_id} subscription_id=${var.aj_subscription_id} secret_access_key=${var.aj_secret_access_key} \""
    is_server          = false
    gossip_encrypt_key = "${var.gossip_encrypt_key}"
    ca_file            = "${var.ca_file}"
    cert_file          = "${var.cert_file}"
    key_file           = "${var.key_file}"
  }
}

data "template_file" "azure-client-west" {
  template = "${file("${path.module}/../files/consul-config-template.hcl")}"
  vars = {
    datacenter         = "west-azure"
    log_level          = "DEBUG"
    retry_join         = "\"provider=azure tag_name=${var.aj_tag_name} tag_value=${var.azure_west_dc} tenant_id=${var.aj_tenant_id} client_id=${var.aj_client_id} subscription_id=${var.aj_subscription_id} secret_access_key=${var.aj_secret_access_key} \""
    is_server          = false
    gossip_encrypt_key = "${var.gossip_encrypt_key}"
    ca_file            = "${var.ca_file}"
    cert_file          = "${var.cert_file}"
    key_file           = "${var.key_file}"
  }
}

data "template_file" "azure-server-west" {
  template = "${file("${path.module}/../files/consul-config-template.hcl")}"
  vars = {
    datacenter         = "west-azure"
    log_level          = "DEBUG"
    retry_join         = "\"provider=azure tag_name=${var.aj_tag_name} tag_value=${var.azure_west_dc} tenant_id=${var.aj_tenant_id} client_id=${var.aj_client_id} subscription_id=${var.aj_subscription_id} secret_access_key=${var.aj_secret_access_key} \""
    is_server          = true
    non_voting_server  = false
    retry_join_wan         = "${local.retry_list_values}"
    #retry_join_wan     = "\"provider=azure tag_name=ehron-server-aj tag_value=consul-server tenant_id=${var.aj_tenant_id} client_id=${var.aj_client_id} subscription_id=${var.aj_subscription_id} secret_access_key=${var.aj_secret_access_key} \""
    connect_enabled    = true
    primary_datacenter = "east-gcp"
    gossip_encrypt_key = "${var.gossip_encrypt_key}"
    ca_file            = "${var.ca_file}"
    cert_file          = "${var.cert_file}"
    key_file           = "${var.key_file}"
  }
}

data "template_file" "azure-server-east" {
  template = "${file("${path.module}/../files/consul-config-template.hcl")}"
  vars = {
    datacenter         = "east-azure"
    log_level          = "DEBUG"
    retry_join         = "\"provider=azure tag_name=${var.aj_tag_name} tag_value=${var.azure_east_dc} tenant_id=${var.aj_tenant_id} client_id=${var.aj_client_id} subscription_id=${var.aj_subscription_id} secret_access_key=${var.aj_secret_access_key} \""
    is_server          = true
    non_voting_server  = false
    retry_join_wan         = "${local.retry_list_values}"
    #retry_join_wan     = "\"provider=azure tag_name=ehron-server-aj tag_value=consul-server tenant_id=${var.aj_tenant_id} client_id=${var.aj_client_id} subscription_id=${var.aj_subscription_id} secret_access_key=${var.aj_secret_access_key}\""
    connect_enabled    = true
    primary_datacenter = "east-gcp"
    gossip_encrypt_key = "${var.gossip_encrypt_key}"
    ca_file            = "${var.ca_file}"
    cert_file          = "${var.cert_file}"
    key_file           = "${var.key_file}"
  }
}