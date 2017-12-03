#!/bin/bash

# Install BIND utility
sudo apt-get install bind9 bind9utils bind9-doc
# Create directories if not present
sudo mkdir -p /etc/bind/zones
# Add flag to set BIND to IPv4 mode 
sudo cp bind9 /etc/default/bind9
# DNS options
sudo cp named.conf.options /etc/bind/named.conf.options
# DNS local options
sudo cp named.conf.local /etc/bind/named.conf.local
# Forward zone file
sudo cp db.group9.csc.com /etc/bind/zones/db.group9.csc.com
# Reverse zone file
sudo cp db.192.168 /etc/bind/zones/db.192.168
# Restart BIND
sudo service bind9 restart