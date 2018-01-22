#!/bin/bash

# Install Apache
sudo apt install apache2 -y
sudo cp configs/apache2.conf /etc/apache2/apache2.conf
sudo systemctl restart apache2

# Install MySQL
# password = "inseguro"
sudo apt install mysql-server -y

# Install PHP
sudo apt install php libapache2-mod-php php-mcrypt php-mysql -y

# Get the certificate and self signed key
sudo mkdir /root/certificates -p
sudo cp keys/sp.crt /root/certificates/sp.crt
sudo cp keys/sp.key /root/certificates/sp.key
sudo cp keys/my-ca.crt /root/certificates/my-ca.crt
sudo cp keys/my-ca.key /root/certificates/my-ca.key
sudo chmod 0755 /root/certificates/sp.crt
sudo chmod 0755 /root/certificates/sp.key
sudo chmod 0755 /root/certificates/my-ca.crt
sudo chmod 0755 /root/certificates/my-ca.key

# Setup Apache Virtual Hosts
sudo mkdir -p /var/www/group9.csc.com/public_html
sudo mkdir -p /var/www/group9.csc.com/public_html/resource
sudo chown -R $USER:$USER /var/www/group9.csc.com/public_html
sudo chmod -R 755 /var/www
sudo cp configs/index.html /var/www/group9.csc.com/public_html/index.html
sudo cp configs/resource/resource.html /var/www/group9.csc.com/public_html/resource/index.html
sudo cp configs/group9.csc.com.conf /etc/apache2/sites-available/group9.csc.com.conf
# Configure Apache2 to use SSL
sudo cp configs/default-ssl.conf /etc/apache2/sites-available/default-ssl.conf

# Install Shibboleth
sudo apt install libapache2-mod-shib2 -y 
sudo shib-keygen -h sp.group9.csc.com -f
sudo cp configs/shibboleth2.xml /etc/shibboleth/shibboleth2.xml

# Activate new modules and deactivate default
sudo a2enmod ssl headers &&
sudo a2enmod shib2 &&
sudo a2ensite group9.csc.com.conf &&
sudo a2ensite default-ssl.conf &&
sudo a2dissite 000-default.conf &&
sudo systemctl reload apache2 &&
sudo service apache2 restart

sudo /etc/init.d/shibd restart
sudo /etc/init.d/apache2 restart
