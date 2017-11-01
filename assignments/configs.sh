#!/bin/bash

# Delete all network connections
sudo nmcli connection delete `nmcli -f NAME c | grep -v NAME`

# Machine 1
if [ `grep '^' /sys/class/net/enp0s3/address` = "42:06:94:20:69:11" ]
	then
		sudo nmcli connection add type ethernet ifname enp0s3 con-name "Internet"
		sudo nmcli connection add type ethernet ifname enp0s8 con-name "eth0" ip4 192.168.1.1/24
fi

# Machine 2
if [ `grep '^' /sys/class/net/enp0s3/address` = "42:06:94:20:69:21" ]
	then
		# Change hostname
		sudo sed -i 's/machine1/machine2/g' /etc/hostname
		sudo sed -i 's/127.0.1.1	machine1/127.0.1.1	machine2/g' /etc/hosts
		# Add connections
		sudo nmcli connection add type ethernet ifname enp0s3 con-name "eth0" ip4 192.168.1.2/24
		sudo nmcli connection add type ethernet ifname enp0s8 con-name "eth1" ip4 192.168.3.1/24
		sudo nmcli connection add type ethernet ifname enp0s9 con-name "eth2" ip4 192.168.4.1/24
fi

# Machine 3
if [ `grep '^' /sys/class/net/enp0s3/address` = "42:06:94:20:69:31" ]
 	then
 		sudo sed -i 's/machine1/machine3/g' /etc/hostname
		sudo sed -i 's/127.0.1.1	machine1/127.0.1.1	machine3/g' /etc/hosts
 		sudo nmcli connection add type ethernet ifname enp0s3 con-name "eth0" ip4 192.168.3.2/24
fi

# Machine 4
if [ `grep '^' /sys/class/net/enp0s3/address` = "42:06:94:20:69:41" ]
	then
		sudo sed -i 's/machine1/machine4/g' /etc/hostname
		sudo sed -i 's/127.0.1.1	machine1/127.0.1.1	machine4/g' /etc/hosts
		sudo nmcli connection add type ethernet ifname enp0s3 con-name "eth0" ip4 192.168.4.2/24
fi




