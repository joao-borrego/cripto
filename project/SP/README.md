# SP configuration

## Install Apache 

First apache server is installed to futerely simulate a protected resource and to generate its protection using shibboleth.

```
sudo apt install apache2 -y
```

To avoid a syntax warning message about the global servername, run the following command. This will simply add a `ServerName` directive pointing to the primary domain (192.168.1.1).

```
sudo cp configs/apache2.conf /etc/apache2/apache2.conf
```

Restar Apache to implement the changes.

```
sudo systemctl restart apache2
```

## Install MySQL

This will be necessary for the shibboleth inner mechanisms.
Use `inseguro` as the password.

```
sudo apt install mysql-server -y
```


## Install PHP

```
sudo apt install php libapache2-mod-php php-mcrypt php-mysql -y
```

## Get the certificate and self signed key

This was previously generated using the method of [assignment 6](https://github.com/jsbruglie/cripto/blob/dev/assignments/assignment6.md), now just copy it to a directory to use after and give it `0755` permissions (User:`rwx` Group:`r-x` World:`r-x`).

```
mkdir /root/certificates
sudo cp configs/sp.crt /root/certificates/sp.crt
sudo cp configs/sp.key /root/certificates/sp.key
sudo chmod 0755 /root/certificates/sp.crt
sudo chmod 0755 /root/certificates/sp.key
```

## Configure Apache2 to use SSL

Instead of using `000-default.conf` file in the `/etc/apache2/sites-available/`, use `default-ssl.conf` file that contains some default SSL configuration already. For that copy the `configs/default-ssl.conf` to `/etc/apache2/sites-available/`. 

``
sudo cp configs/default-ssl.conf /etc/apache2/sites-available/default-ssl.conf
```

This file was edited for Apache to look for the SSL certificate and key in another location and to change the `ServerName`.


## Setup Apache Virtual Hosts



## Activate SSL module 
```
sudo a2enmod ssl headers 
```

## Deactivate default Virtual Host
```
sudo a2ensite default-ssl.conf
```

Deactivate the default [READ THIS](https://webmasters.stackexchange.com/questions/83633/have-disabled-apache-site-config-file-000-default-conf-but-it-still-seems-activ)
```
sudo a2dissite 000-default.conf 
```

Apply the changes
```
sudo systemctl reload apache2 
sudo service apache2 restart
```

