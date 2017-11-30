#!/bin/bash

#sudo nano /usr/share/lightdm/lightdm.conf.d/20-lubuntu.conf
#[Seat:*]
#user-session=Lubuntu
#[SeatDefaults]
#autologin-user=user
#autologin-user-timeout=0

# SP
if [ `grep '^' /sys/class/net/enp0s3/address` = "08:00:43:53:43:11" ]
	then
		sudo nmcli connection delete "Wired connection 1"
		sudo nmcli connection delete "Wired connection 2"
		sudo nmcli connection add type ethernet ifname enp0s3 con-name "Internet"
		sudo nmcli connection add type ethernet ifname enp0s8 con-name "eth0" ip4 192.168.1.1/24

		sudo iptables -P FORWARD ACCEPT
		sudo iptables -F FORWARD
		sudo iptables -t nat -F
		sudo iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE
		sudo apt install iptables-persistent
		sudo iptables-save > /etc/iptables.rules

		sudo cp DNS/bind9 /etc/default/bind9
		sudo cp DNS/named.conf.options /etc/bind/named.conf.options
		sudo cp DNS/named.conf.local /etc/bind/named.conf.local
		sudo cp DNS/db.group9.csc.com /etc/bind/zones/db.group9.csc.com
		sudo cp DNS/db.192.168 /etc/bind/zones/db.192.168
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

# WAYP
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


