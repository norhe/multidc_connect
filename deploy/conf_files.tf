## Google
data "template_file" "gce-client-east" {
  template = "${file("${path.module}/../files/consul-config-template.hcl")}"
  vars = {
    datacenter                    = "east-gcp"
    log_level                     = "DEBUG"
    retry_join                    = "\"provider=gce project_name=eq-env tag_value=consul-east-gcp\""
    is_server                     = false
    enable_central_service_config = true
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
    retry_join_wan     = "\"provider=gce project_name=eq-env tag_value=consul-server\""
    connect_enabled    = true
    primary_datacenter = "east-gcp"

    enable_central_service_config = "${var.enable_central_service_config}"
    config_entries = "${var.config_entries}"
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
    retry_join_wan     = "\"provider=gce project_name=eq-env tag_value=consul-server\""
    connect_enabled    = true
    primary_datacenter = "east-gcp"   
  }
}

## Azure
data "template_file" "azure-client-east" {
  template = "${file("${path.module}/../files/consul-config-template.hcl")}"
  vars = {
    datacenter = "east-azure"
    log_level  = "DEBUG"
    retry_join = "\"provider=azure tag_name=${var.aj_tag_name} tag_value=${var.azure_east_dc} tenant_id=${var.aj_tenant_id} client_id=${var.aj_client_id} subscription_id=${var.aj_subscription_id} secret_access_key=${var.aj_secret_access_key} \""
    is_server  = false
  }
}

data "template_file" "azure-client-west" {
  template = "${file("${path.module}/../files/consul-config-template.hcl")}"
  vars = {
    datacenter = "west-azure"
    log_level  = "DEBUG"
    retry_join = "\"provider=azure tag_name=${var.aj_tag_name} tag_value=${var.azure_west_dc} tenant_id=${var.aj_tenant_id} client_id=${var.aj_client_id} subscription_id=${var.aj_subscription_id} secret_access_key=${var.aj_secret_access_key} \""
    is_server  = false
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
    retry_join         = "\"provider=azure tag_name=${var.aj_tag_name} tag_value=${var.azure_east_dc} tenant_id=${var.aj_tenant_id} client_id=${var.aj_client_id} subscription_id=${var.aj_subscription_id} secret_access_key=${var.aj_secret_access_key} \""
    is_server          = true
    non_voting_server  = false
    retry_join_wan     = "\"provider=azure tag_name=ehron-server-aj tag_value=consul-server tenant_id=${var.aj_tenant_id} client_id=${var.aj_client_id} subscription_id=${var.aj_subscription_id} secret_access_key=${var.aj_secret_access_key}\""
    connect_enabled    = true
    primary_datacenter = "east-gcp"
  }
}