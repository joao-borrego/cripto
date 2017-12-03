#!/bin/bash

sudo mkdir -p /etc/bind/zones
sudo cp bind9 /etc/default/bind9
sudo cp named.conf.options /etc/bind/named.conf.options
sudo cp named.conf.local /etc/bind/named.conf.local
sudo cp db.group9.csc.com /etc/bind/zones/db.group9.csc.com
sudo cp db.192.168 /etc/bind/zones/db.192.168