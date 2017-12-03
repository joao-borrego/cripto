#!/bin/bash

# SP
if [ `grep '^' /sys/class/net/enp0s3/address` = "08:00:43:53:43:11" ]
	then
		# Change hostname
		sudo sed -i 's/machine1/sp/g' /etc/hostname
		sudo sed -i 's/127.0.1.1	machine1/127.0.1.1	sp/g' /etc/hosts
		# Add connections
		sudo nmcli connection delete "Wired connection 1"
		sudo nmcli connection delete "Wired connection 2"
		sudo nmcli connection add type ethernet ifname enp0s3 con-name "Internet"
		sudo nmcli connection add type ethernet ifname enp0s8 con-name "eth0" ip4 192.168.1.1/24
		# Forward packets
		sudo iptables -P FORWARD ACCEPT
		sudo iptables -F FORWARD
		sudo iptables -t nat -F
		sudo iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE
		sudo apt install iptables-persistent
		sudo sh -c 'iptables-save > /etc/iptables.rules'
		# Configure DNS
		(cd DNS; sh dns_config.sh)
fi

# Browser
if [ `grep '^' /sys/class/net/enp0s3/address` = "08:00:43:53:43:21" ]
	then
		sudo nmcli connection delete "Wired connection 1"
		sudo nmcli connection add type ethernet ifname enp0s3 con-name "eth0" ip4 192.168.1.2/24
fi

# IdP1
if [ `grep '^' /sys/class/net/enp0s3/address` = "08:00:43:53:43:31" ]
 	then
		sudo nmcli connection delete "Wired connection 1"
 		sudo nmcli connection add type ethernet ifname enp0s3 con-name "eth0" ip4 192.168.1.3/24
fi

# WAYF
if [ `grep '^' /sys/class/net/enp0s3/address` = "08:00:43:53:43:41" ]
	then
		sudo nmcli connection delete "Wired connection 1"
		sudo nmcli connection add type ethernet ifname enp0s3 con-name "eth0" ip4 192.168.1.4/24
fi

# IdP2
if [ `grep '^' /sys/class/net/enp0s3/address` = "08:00:43:53:43:51" ]
	then
		sudo nmcli connection delete "Wired connection 1"
		sudo nmcli connection add type ethernet ifname enp0s3 con-name "eth0" ip4 192.168.1.5/24
fi

