#!/bin/bash
# Auto-login
# sudo nano /usr/share/lightdm/lightdm.conf.d/20-lubuntu.conf
# cat >> /usr/share/lightdm/lightdm.conf.d/20-lubuntu.conf <<EOF
# autologin-user=user
# autologin-user-timeout=0
# EOF

# Number of interfaces
#ls -A /sys/class/net | wc -l
# Mac address
#ip addr | grep link/ether | awk '{print $2}'

# Machine 1
#if [ `ls -A /sys/class/net | wc -l` = "3" ]
if [ `grep '^' /sys/class/net/enp0s3/address` = "42:06:94:20:69:11" ]
	then
		sudo nmcli connection add type ethernet ifname enp0s3 con-name "Internet"
		sudo nmcli connection add type ethernet ifname enp0s8 con-name "eth0" ip4 192.168.1.1/24
fi

# Machine 2
#if [ `ls -A /sys/class/net | wc -l` = "4" ]
if [ `grep '^' /sys/class/net/enp0s3/address` = "42:06:94:20:69:21" ]
	then
		sudo nmcli connection add type ethernet ifname enp0s3 con-name "eth0" ip4 192.168.1.2/24
		sudo nmcli connection add type ethernet ifname enp0s8 con-name "eth1" ip4 192.168.3.1/24
		sudo nmcli connection add type ethernet ifname enp0s9 con-name "eth2" ip4 192.168.4.1/24
fi

# # Machine 3
#if [ `ip addr | grep link/ether | awk '{print $2}'` = "42:06:94:20:69:31" ]
if [ `grep '^' /sys/class/net/enp0s3/address` = "42:06:94:20:69:31" ]
 	then
 		sudo nmcli connection add type ethernet ifname enp0s3 con-name "eth0" ip4 192.168.3.2/24
fi

# Machine 4
#if [ `ip addr | grep link/ether | awk '{print $2}'` = "42:06:94:20:69:41" ]
if [ `grep '^' /sys/class/net/enp0s3/address` = "42:06:94:20:69:41" ]
	then
		sudo nmcli connection add type ethernet ifname enp0s3 con-name "eth0" ip4 192.168.4.2/24
fi
