#! /bin/bash

# disable resolved
sudo systemctl disable systemd-resolved
sudo systemctl stop systemd-resolved

sudo rm /etc/resolv.conf

echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf

sudo apt-get update
sudo apt-get install dnsmasq

echo "nameserver 127.0.0.1 
nameserver 8.8.8.8" |sudo tee /etc/resolv.conf

sudo systemctl restart dnsmasq