#! /bin/bash

# disable resolved
sudo systemctl disable systemd-resolved
sudo systemctl stop systemd-resolved

sudo rm /etc/resolv.conf

echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf

DEBIAN_FRONTEND=noninteractive sudo apt-get update
DEBIAN_FRONTEND=noninteractive sudo apt-get --yes install dnsmasq

echo "nameserver 127.0.0.1 
nameserver 8.8.8.8" |sudo tee /etc/resolv.conf

echo "127.0.0.1 $(hostname)" | sudo tee -a /etc/hosts

sudo systemctl restart dnsmasq