#!/bin/bash

# Machine 1
if [ `grep '^' /sys/class/net/enp0s3/address` = "42:06:94:20:69:11" ]
	then
		sudo nmcli connection delete "Wired Connection 1"
		sudo nmcli connection delete "Wired Connection 2"
		sudo nmcli connection add type ethernet ifname enp0s3 con-name "Internet"
		sudo nmcli connection add type ethernet ifname enp0s8 con-name "eth0" ip4 192.168.1.1/24
fi

# Machine 2
if [ `grep '^' /sys/class/net/enp0s3/address` = "42:06:94:20:69:21" ]
	then
		sudo nmcli connection delete "Wired Connection 1"
		sudo nmcli connection delete "Wired Connection 2"
		sudo nmcli connection delete "Wired Connection 3"
		sudo nmcli connection add type ethernet ifname enp0s3 con-name "eth0" ip4 192.168.1.2/24
		sudo nmcli connection add type ethernet ifname enp0s8 con-name "eth1" ip4 192.168.3.1/24
		sudo nmcli connection add type ethernet ifname enp0s9 con-name "eth2" ip4 192.168.4.1/24
fi

# Machine 3
if [ `grep '^' /sys/class/net/enp0s3/address` = "42:06:94:20:69:31" ]
 	then
		sudo nmcli connection delete "Wired Connection 1"
 		sudo nmcli connection add type ethernet ifname enp0s3 con-name "eth0" ip4 192.168.3.2/24
fi

# Machine 4
if [ `grep '^' /sys/class/net/enp0s3/address` = "42:06:94:20:69:41" ]
	then
		sudo nmcli connection delete "Wired Connection 1"
		sudo nmcli connection add type ethernet ifname enp0s3 con-name "eth0" ip4 192.168.4.2/24
fi




