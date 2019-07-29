#! /bin/bash

DC="$(curl http://127.0.0.1:8500/v1/catalog/node/$(hostname) | jq -r .Node.Datacenter)"

curl -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/

if [ $? -eq 0 ]; then
  EXT_ADDR=$(curl -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip)
else
  EXT_ADDR=$(curl -H 'Metadata:true' http://169.254.169.254/metadata/instance?api-version=2019-06-04 |jq -r .network.interface[0].ipv4.ipAddress[0].publicIpAddress)
fi  

printf '#! /bin/bash \n\nconsul connect envoy -mesh-gateway -register \
          -service "gateway-%s" \
          -address "{{ GetPrivateIP }}:2000" \
          -wan-address "%s:3000"' $DC $EXT_ADDR | sudo tee /etc/consul/run_mesh_gateway.sh

sudo chmod a+x /etc/consul/run_mesh_gateway.sh

echo "Creating Consul Proxy..."

cat <<EOF | sudo tee /lib/systemd/system/mesh_gateway.service
[Unit]
Description=Consul Mesh Gateway (Envoy)
After=network.target
After=consul.target

[Service]
Type=simple
User=consul
ExecStart=/etc/consul/run_mesh_gateway.sh 
Restart=always
SyslogIdentifier=consul_mesh_gateway
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable mesh_gateway.service
sudo systemctl start mesh_gateway.service