# 
# Configure hostname and network connections
#

# Default hostname from Base machine
default_host='user'

# SP
if [ `grep '^' /sys/class/net/enp0s3/address` = "08:00:43:53:43:11" ]
	then

		# Setup connections
		sudo nmcli connection delete "Wired connection 1"
		sudo nmcli connection delete "Wired connection 2"
		sudo nmcli connection add type ethernet ifname enp0s3 con-name "Internet"
		sudo nmcli connection add type ethernet ifname enp0s8 con-name "eth0" ip4 192.168.1.1/24
		# Change hostname to sp
		sudo sed -i 's/'$default_host'/sp/g' /etc/hostname
		sudo sed -i 's/127.0.1.1	'$default_host'/127.0.1.1	sp/g' /etc/hosts
fi

# Browser
if [ `grep '^' /sys/class/net/enp0s3/address` = "08:00:43:53:43:21" ]
	then
		sudo nmcli connection delete "Wired connection 1"
		sudo nmcli connection delete "Wired connection 2"
		sudo nmcli connection add type ethernet ifname enp0s3 con-name "Internet"
		sudo nmcli connection add type ethernet ifname enp0s3 con-name "eth0" ip4 192.168.1.2/24
		# Change hostname to browser
		sudo sed -i 's/'$default_host'/browser/g' /etc/hostname
		sudo sed -i 's/127.0.1.1	'$default_host'/127.0.1.1	browser/g' /etc/hosts
fi

# IdP
if [ `grep '^' /sys/class/net/enp0s3/address` = "08:00:43:53:43:31" ]
 	then
		sudo nmcli connection delete "Wired connection 1"
		sudo nmcli connection delete "Wired connection 2"
		sudo nmcli connection add type ethernet ifname enp0s3 con-name "Internet"
 		sudo nmcli connection add type ethernet ifname enp0s3 con-name "eth0" ip4 192.168.1.3/24
		# Change hostname to idp
		sudo sed -i 's/'$default_host'/idp/g' /etc/hostname
		sudo sed -i 's/127.0.1.1	'$default_host'/127.0.1.1	idp/g' /etc/hosts
fi
