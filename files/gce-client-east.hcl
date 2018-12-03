client_addr      = "0.0.0.0"
data_dir         = "/opt/consul"
datacenter       = "east"
log_level        = "INFO"
server           = false
retry_join       = [
    "provider=gce project_name=eq-env tag_value=consul-east-dc"
]
ports            = {
    grpc         = 8502
}