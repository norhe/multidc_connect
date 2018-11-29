#! /bin/bash

SERVICE=$1

echo "Installing Docker"

DEBIAN_FRONTEND=noninteractive sudo apt-get update && DEBIAN_FRONTEND=noninteractive sudo apt-get --yes install docker.io

echo "Extracting image..."

sudo docker run --rm --entrypoint cat envoyproxy/envoy /usr/local/bin/envoy >/tmp/envoy

DEBIAN_FRONTEND=noninteractive sudo apt-get --yes remove docker.io
sudo ip link del docker0
echo "Cleaning up docker..."

sudo chmod a+x /tmp/envoy

sudo mv /tmp/envoy /usr/local/bin/envoy

consul connect envoy --bootstrap -sidecar-for $SERVICE >/tmp/envoy.conf

sudo mkdir -p /etc/envoy
sudo mv /tmp/envoy.conf /etc/envoy/envoy.conf

cat <<EOF | sudo tee /lib/systemd/system/envoy_proxy.service
[Unit]
Description=Envoy Proxy
After=network.target
[Service]
Type=simple
User=ubuntu
ExecStart=/usr/local/bin/envoy --config-path /etc/envoy/envoy.conf
Restart=always
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable envoy_proxy.service
sudo systemctl start envoy_proxy.service

echo "Envoy installed!"