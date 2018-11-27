bootstrap_expect   = 3
client_addr        = "0.0.0.0"
data_dir           = "/opt/consul"
datacenter         = "west"
log_level          = "INFO"
server             = true
ui                 = true
non_voting_server  = false

retry_join        = [
    "provider=gce project_name=eq-env tag_value=consul-server-west"
]

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

connect = {
    enabled = true
}