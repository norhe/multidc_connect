#! /bin/bash

echo "Installing Docker"

DEBIAN_FRONTEND=noninteractive sudo apt-get update && DEBIAN_FRONTEND=noninteractive sudo apt-get --yes install docker.io

echo "Extracting image..."

sudo docker run --rm --entrypoint cat envoyproxy/envoy /usr/local/bin/envoy >/tmp/envoy

sudo chmod a+x /tmp/envoy

sudo mv /tmp/envoy /usr/local/bin/envoy

echo "Envoy installed!"