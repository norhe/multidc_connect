client_addr      = "0.0.0.0"
data_dir         = "/opt/consul"
datacenter       = "${datacenter}"
log_level        = "${log_level}"

retry_join       = [
    ${retry_join}
]
ports            = {
    grpc         = 8502
}

# server
server             = ${is_server}
%{ if is_server }
bootstrap_expect   = 3
ui                 = true
non_voting_server  = ${non_voting_server}

# Consul datacenter federation auto-join
retry_join_wan    = [
    ${retry_join_wan}
]

# Enterprise autopilot features
autopilot         = {
    cleanup_dead_servers      = true,
    last_contact_threshold    ="200ms",
    max_trailing_logs         = 250,
    server_stabilization_time = "10s",
    redundancy_zone_tag       = "zone",
    disable_upgrade_migration = false,
    upgrade_version_tag       = "",
}
node_meta = { },

%{ if connect_enabled}
# Connect settings
connect = {
    enabled = ${connect_enabled}
}
primary_datacenter = "${primary_datacenter}"
%{ endif ~}

%{ endif }