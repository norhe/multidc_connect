data "template_file" "gce-client-east" {
  template = "${file("${path.module}/../files/consul-config-template.hcl")}"
  vars = {
    datacenter = "east-gcp"
    log_level = "DEBUG"
    retry_join = "\"provider=gce project_name=eq-env tag_value=consul-east-gcp\""
    is_server = false
  }
}

data "template_file" "gce-client-west" {
  template = "${file("${path.module}/../files/consul-config-template.hcl")}"
  vars = {
    datacenter = "west-gcp"
    log_level = "DEBUG"
    retry_join = "\"provider=gce project_name=eq-env tag_value=consul-west-gcp\""
    is_server = false
  }
}

data "template_file" "gce-server-west" {
  template = "${file("${path.module}/../files/consul-config-template.hcl")}"
  vars = {
    datacenter = "west-gcp"
    log_level = "DEBUG"
    retry_join = "\"provider=gce project_name=eq-env tag_value=consul-west-gcp\""
    is_server = true
    non_voting_server = false
    retry_join_wan = "\"provider=gce project_name=eq-env tag_value=consul-server\""
    connect_enabled = true
    primary_datacenter = "east-gcp"
  }
}

data "template_file" "gce-server-east" {
  template = "${file("${path.module}/../files/consul-config-template.hcl")}"
  vars = {
    datacenter = "east-gcp"
    log_level = "DEBUG"
    retry_join = "\"provider=gce project_name=eq-env tag_value=consul-east-gcp\""
    is_server = true
    non_voting_server = false
    retry_join_wan = "\"provider=gce project_name=eq-env tag_value=consul-server\""
    connect_enabled = true
    primary_datacenter = "east-gcp"
  }
}