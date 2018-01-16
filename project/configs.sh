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

		# Setup connections
		sudo nmcli connection delete "Wired connection 1"
		sudo nmcli connection delete "Wired connection 2"
		sudo nmcli connection add type ethernet ifname enp0s3 con-name "Internet"
		sudo nmcli connection add type ethernet ifname enp0s8 con-name "eth0" ip4 192.168.1.1/24
		sudo sed -i 's/machine1/sp/g' /etc/hostname
		sudo sed -i 's/127.0.1.1	machine1/127.0.1.1	sp/g' /etc/hosts
		sudo apt update

		# Configures IP forwarding
		sudo cp DNS/sysctl.conf /etc/sysctl.conf
		sudo service procps restart
		sudo iptables -P FORWARD ACCEPT
		sudo iptables -F FORWARD
		sudo iptables -t nat -F
		sudo iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE
		sudo apt install iptables-persistent
		sudo bash -c "iptables-save > /etc/iptables.rules"

		# Install DNS configs
		sudo apt install bind9 bind9utils bind9-doc
		sudo cp DNS/bind9 /etc/default/bind9
		sudo cp DNS/named.conf.options /etc/bind/named.conf.options
		sudo cp DNS/named.conf.local /etc/bind/named.conf.local
		sudo mkdir /etc/bind/zones
		sudo cp DNS/db.group9.csc.com /etc/bind/zones/db.group9.csc.com
		sudo cp DNS/db.192.168 /etc/bind/zones/db.192.168
		sudo service bind9 restart
		sudo cp DNS/head /etc/resolvconf/resolv.conf.d/head
		sudo resolvconf -u

		# Install Apache
		sudo apt install apache2
		sudo cp SP/apache2.conf /etc/apache2/apache2.conf
		sudo systemctl restart apache2
		sudo ufw allow in "Apache Full"

		# Install MySQL
		sudo apt install mysql-server

		# Install PHP
		sudo apt install php libapache2-mod-php php-mcrypt php-mysql
		sudo cp SP/dir.conf /etc/apache2/mods-enabled/dir.conf
		sudo systemctl restart apache2

		########## SIMPLESAMLPHP ##########
		# Setup Apache Virtual Hosts
		sudo mkdir -p /var/www/group9.csc.com/public_html
		sudo chown -R $USER:$USER /var/www/group9.csc.com/public_html
		sudo chmod -R 755 /var/www
		sudo cp SP/index.html /var/www/group9.csc.com/public_html/index.html
		sudo cp SP/group9.csc.com.conf /etc/apache2/sites-available/group9.csc.com.conf
		sudo a2ensite group9.csc.com.conf
		sudo a2dissite 000-default.conf
		sudo systemctl restart apache2

		# Install SimpleSAMLphp
		sudo wget https://github.com/simplesamlphp/simplesamlphp/releases/download/v1.15.0/simplesamlphp-1.15.0.tar.gz
		tar zxf simplesamlphp-1.15.0.tar.gz
		sudo cp -a simplesamlphp-1.15.0/. /var/simplesamlphp
		rm -rf simplesamlphp-1.15.0
		sudo apt install php-xml php-mbstring php-curl php-memcache php-ldap memcached
		sudo cp SP/config.php /var/simplesamlphp/config/config.php
		sudo systemctl restart apache2

		########## SHIBBOLETH ##########
		# Shibboleth SP
		sudo apt install libapache2-mod-shib2
		sudo a2enmod shib2
		sudo cp SP/shibboleth2.xml /etc/shibboleth/shibboleth2.xml
		sudo /etc/init.d/shibd restart
		sudo /etc/init.d/apache2 restart

fi

# Browser
if [ `grep '^' /sys/class/net/enp0s3/address` = "08:00:43:53:43:21" ]
	then
		sudo nmcli connection delete "Wired connection 1"
		sudo nmcli connection add type ethernet ifname enp0s3 con-name "eth0" ip4 192.168.1.2/24
		sudo sed -i 's/machine1/browser/g' /etc/hostname
		sudo sed -i 's/127.0.1.1	machine1/127.0.1.1	browser/g' /etc/hosts
		# DNS Client
		sudo cp DNS/head /etc/resolvconf/resolv.conf.d/head
		sudo resolvconf -u
fi

# IdP
if [ `grep '^' /sys/class/net/enp0s3/address` = "08:00:43:53:43:31" ]
 	then
		sudo nmcli connection delete "Wired connection 1"
 		sudo nmcli connection add type ethernet ifname enp0s3 con-name "eth0" ip4 192.168.1.3/24
		sudo sed -i 's/machine1/idp/g' /etc/hostname
		sudo sed -i 's/127.0.1.1	machine1/127.0.1.1	idp/g' /etc/hosts
		# DNS Client
		sudo cp DNS/head /etc/resolvconf/resolv.conf.d/head
		sudo resolvconf -u
fi


