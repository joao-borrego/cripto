#!/bin/bash

#
# Configure DNS and clients
#

# SP
if [ `grep '^' /sys/class/net/enp0s3/address` = "08:00:43:53:43:11" ]
	then
		# Install DNS configs
		sudo apt install bind9 bind9utils bind9-doc -y
		sudo cp configs/bind9 /etc/default/bind9
		sudo cp configs/named.conf.options /etc/bind/named.conf.options
		sudo cp configs/named.conf.local /etc/bind/named.conf.local
		sudo mkdir /etc/bind/zones
		sudo cp configs/db.group9.csc.com /etc/bind/zones/db.group9.csc.com
		sudo cp configs/db.192.168 /etc/bind/zones/db.192.168
		sudo service bind9 restart
		sudo cp configs/head /etc/resolvconf/resolv.conf.d/head
		sudo resolvconf -u
fi

# Browser
if [ `grep '^' /sys/class/net/enp0s3/address` = "08:00:43:53:43:21" ]
	then
		# DNS Client
		sudo cp configs/head /etc/resolvconf/resolv.conf.d/head
		sudo resolvconf -u
fi

# IdP
if [ `grep '^' /sys/class/net/enp0s3/address` = "08:00:43:53:43:31" ]
 	then
		# DNS Client
		sudo cp configs/head /etc/resolvconf/resolv.conf.d/head
		sudo resolvconf -u
fi


