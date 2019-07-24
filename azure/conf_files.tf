data "template_file" "azure-client-east" {
  template = "${file("${path.module}/../files/consul-config-template.hcl")}"
  vars = {
    datacenter = "east-azure"
    log_level  = "DEBUG"
    retry_join = "\"provider=azure tag_name=${var.aj_tag_name} tag_value=${var.east_dc} tenant_id=${var.aj_tenant_id} client_id=${var.aj_client_id} subscription_id=${var.aj_subscription_id} secret_access_key=${var.aj_secret_access_key} \""
    is_server  = false
  }
}

data "template_file" "azure-client-west" {
  template = "${file("${path.module}/../files/consul-config-template.hcl")}"
  vars = {
    datacenter = "west-azure"
    log_level  = "DEBUG"
    retry_join = "\"provider=azure tag_name=${var.aj_tag_name} tag_value=${var.west_dc} tenant_id=${var.aj_tenant_id} client_id=${var.aj_client_id} subscription_id=${var.aj_subscription_id} secret_access_key=${var.aj_secret_access_key} \""
    is_server  = false
  }
}

data "template_file" "azure-server-west" {
  template = "${file("${path.module}/../files/consul-config-template.hcl")}"
  vars = {
    datacenter         = "west-azure"
    log_level          = "DEBUG"
    retry_join         = "\"provider=azure tag_name=${var.aj_tag_name} tag_value=${var.west_dc} tenant_id=${var.aj_tenant_id} client_id=${var.aj_client_id} subscription_id=${var.aj_subscription_id} secret_access_key=${var.aj_secret_access_key} \""
    is_server          = true
    non_voting_server  = false
    retry_join_wan     = "\"provider=azure tag_name=ehron-server-aj tag_value=consul-server tenant_id=${var.aj_tenant_id} client_id=${var.aj_client_id} subscription_id=${var.aj_subscription_id} secret_access_key=${var.aj_secret_access_key} \""
    connect_enabled    = true
    primary_datacenter = "east-gcp"
  }
}

data "template_file" "azure-server-east" {
  template = "${file("${path.module}/../files/consul-config-template.hcl")}"
  vars = {
    datacenter         = "east-azure"
    log_level          = "DEBUG"
    retry_join         = "\"provider=azure tag_name=${var.aj_tag_name} tag_value=${var.east_dc} tenant_id=${var.aj_tenant_id} client_id=${var.aj_client_id} subscription_id=${var.aj_subscription_id} secret_access_key=${var.aj_secret_access_key} \""
    is_server          = true
    non_voting_server  = false
    retry_join_wan     = "\"provider=azure tag_name=ehron-server-aj tag_value=consul-server tenant_id=${var.aj_tenant_id} client_id=${var.aj_client_id} subscription_id=${var.aj_subscription_id} secret_access_key=${var.aj_secret_access_key}\""
    connect_enabled    = true
    primary_datacenter = "east-gcp"
  }
}