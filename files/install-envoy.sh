#! /bin/bash

echo "Installing Docker"

sudo apt-get update && sudo apt-get install docker.io

echo "Extracting image..."

sudo docker run --rm --entrypoint cat envoyproxy/envoy /usr/local/bin/envoy >/tmp/envoy

sudo chmod a+x /tmp/envoy

sudo mv /tmp/envoy /usr/local/bin/envoy

echo "Envoy installed!"