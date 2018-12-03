#! /bin/bash

SERVICE=$1

echo "Creating Consul Proxy..."

cat <<EOF | sudo tee /lib/systemd/system/consul_proxy.service
[Unit]
Description=Consul Proxy
After=network.target
[Service]
Type=simple
User=ubuntu
ExecStart=/usr/local/bin/consul connect proxy -sidecar-for $SERVICE
Restart=always
SyslogIdentifier=consul_proxy
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable consul_proxy.service
sudo systemctl start consul_proxy.service

echo "Consul proxy configured!"