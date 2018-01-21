### Service Provider configuration

#### Install Apache 

To implement the SP, we need a web server, since half of Shibboleth runs within it and also our SP will be the host for the protected resource. For that, we will be using Apache.

```
sudo apt install apache2 -y
```

To avoid a syntax warning message about the global servername, run the following command. This will simply add a `ServerName` directive pointing to the primary domain (192.168.1.1).

```
sudo cp configs/apache2.conf /etc/apache2/apache2.conf
```

Restart Apache to implement the changes.

```
sudo systemctl restart apache2
```

#### Install MySQL and PHP

MySQL might be necessary for the shibboleth inner mechanisms and also useful to create a future real application.
Install them and use `inseguro` as the password when prompted.

```
sudo apt install mysql-server -y

sudo apt install php libapache2-mod-php php-mcrypt php-mysql -y
```

#### Get the certificate and self signed keys

To employ TLS, copy the pre-generated keys and certificates to `/root/certificates` and give it `0755` permissions (User:`rwx` Group:`r-x` World:`r-x`).

```
sudo mkdir /root/certificates -p
sudo cp configs/sp.crt /root/certificates/sp.crt
sudo cp configs/sp.key /root/certificates/sp.key
sudo chmod 0755 /root/certificates/sp.crt
sudo chmod 0755 /root/certificates/sp.key
```

#### Setup Apache Virtual Hosts

Create a directory in `/var/www/group9.csc.com/` to keep the `index.html`, this is the page that appears when the user lands in `https://sp.group9.csc.com` or `http://sp.group9.csc.com`. And also a directory to keep the protected resource, which will be accessed via `https://sp.group9.csc.com/resource` or `http://sp.group9.csc.com/resource`.

```
sudo mkdir -p /var/www/group9.csc.com/public_html
sudo mkdir -p /var/www/group9.csc.com/public_html/resource
```

Change the ownership of the directory to user and user group. Give it `0755` permissions.

```
sudo chown -R $USER:$USER /var/www/group9.csc.com/public_html
sudo chmod -R 755 /var/www
```

Copy the pre-generated `configs/index.html` and `configs/resource/resource.html` to the new directories, or create your own.

```
sudo cp configs/index.html /var/www/group9.csc.com/public_html/index.html
sudo cp configs/resource/resource.html /var/www/group9.csc.com/public_html/resource/index.html
```

Copy `configs/group9.csc.com.conf` to `/etc/apache2/sites-available/`. This is the virtual host config file for HTTP requests.

```
sudo cp configs/group9.csc.com.conf /etc/apache2/sites-available/group9.csc.com.conf
```


### Configure Apache2 to use SSL

Instead of using `000-default.conf` file in the `/etc/apache2/sites-available/`, use `default-ssl.conf` file that contains some default SSL configuration already. For that copy the `configs/default-ssl.conf` to `/etc/apache2/sites-available/`. 

``
sudo cp configs/default-ssl.conf /etc/apache2/sites-available/default-ssl.conf
```

This file was edited for Apache to look for the SSL certificate and key in another location and to change the `ServerName`.






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

