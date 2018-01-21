### Service Provider configuration

#### Install Apache 

To implement the SP, we need a web server, since half of Shibboleth runs within it and also our SP will be the host for the protected resource. For that, we will be using Apache.

```
sudo apt install apache2 -y
```

To avoid a syntax warning message about the global servername, edit the file `/etc/apache2/apache2.conf`. 

```
sudo nano /etc/apache2/apache2.conf
```

And add the following line at the bottom of the file.

```
ServerName 192.168.1.1
```

This will simply add a `ServerName` directive pointing to the primary domain (192.168.1.1).

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

Or generate the [keys] yourself.

#### Setup Apache Virtual Hosts

Create a directory in `/var/www/group9.csc.com/` to keep the main page where the user lands when accessing `https://sp.group9.csc.com` or `http://sp.group9.csc.com`. And also a directory to keep the protected resource, which will be accessed via `https://sp.group9.csc.com/resource` or `http://sp.group9.csc.com/resource`.

```
sudo mkdir -p /var/www/group9.csc.com/public_html
sudo mkdir -p /var/www/group9.csc.com/public_html/resource
```

Change the ownership of the directory to user and user group. Give it `0755` permissions.

```
sudo chown -R $USER:$USER /var/www/group9.csc.com/public_html
sudo chmod -R 755 /var/www
```

Copy the pre-generated `configs/index.html` and `configs/resource/resource.html` to the new directories, or create your own, this can be any application you want.

```
sudo cp configs/index.html /var/www/group9.csc.com/public_html/index.html
sudo cp configs/resource/resource.html /var/www/group9.csc.com/public_html/resource/index.html
```

##### For HTTP

Copy `/etc/apache2/sites-enabled/000-default.conf` to a new file named `group9.csc.com.conf` at `/etc/apache2/sites-available/`. This is the virtual host config file for HTTP requests on the domain `group9.csc.com`.

```
sudo cp /etc/apache2/sites-enabled/000-default.conf /etc/apache2/sites-available/group9.csc.com.conf
```

The file should look like this:

```
<VirtualHost *:80>
        # The ServerName directive sets the request scheme, hostname and port that
        # the server uses to identify itself. This is used when creating
        # redirection URLs. In the context of virtual hosts, the ServerName
        # specifies what hostname must appear in the request's Host: header to
        # match this virtual host. For the default virtual host (this file) this
        # value is not decisive as it is used as a last resort host regardless.
        # However, you must set it for any further virtual host explicitly.
        #ServerName www.example.com

        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html

        # Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
        # error, crit, alert, emerg.
        # It is also possible to configure the loglevel for particular
        # modules, e.g.
        #LogLevel info ssl:warn

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

        # For most configuration files from conf-available/, which are
        # enabled or disabled at a global level, it is possible to
        # include a line for only one particular virtual host. For example the
        # following line enables the CGI configuration for this host only
        # after it has been globally disabled with "a2disconf".
        #Include conf-available/serve-cgi-bin.conf
        Alias /log/ "/var/log/"
   	<Directory "/var/log/">
	       Options Indexes MultiViews FollowSymLinks
	       AllowOverride None
	       Order deny,allow
	       Deny from all
	       Allow from all
	        Require all granted
   	</Directory>
</VirtualHost>
```

Edit the following lines

```
sudo nano /etc/apache2/sites-available/group9.csc.com.conf
```

```
<VirtualHost *:80>
  ...
	ServerAdmin admin@group9.csc.com
	ServerName sp.group9.csc.com
	ServerAlias www.group9.csc.com
	DocumentRoot /var/www/group9.csc.com/public_html
	Redirect /resource https://sp.group9.csc.com/resource

	Alias /resource/ /var/www/group9.csc.com/public_html/resource/
    <Location /resource/>
            AuthType shibboleth
            ShibRequestSetting requireSession 1
            Require valid-user
    </Location>
  ...
</VirtualHost>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
```

`<VirtualHost *:80>` lets the server know to accept anything on port 80.

`ServerAdmin` is just the administration email.

`ServerName` and `ServerAlias` tell the server that not only will `sp.group9.csc.com` work, but so will `www.group9.csc.com` if the user requests it.

`DocumentRoot` is where Apache will look for the website files to display.

`Redirect` blocks non-SSL access, redirecting an HTTP request to a HTTPS one. This is **very important**, refer to [].

```
 <Location /resource/>
        AuthType shibboleth
        ShibRequestSetting requireSession 1
        Require valid-user
</Location>
```
Sets up apache to enable shibboleth. The two generic commands around the middle one are Apache's way of signaling that you want the module to run, and that any authenticated user is acceptable. The middle setting tells the SP to perform authentication any time a session isn't already in place, which ensures that the authorization rule can be met [1].

##### For HTTPS

Now we will do the same for HTTPS requests, but also define the configuration for the SSL module. Edit the `/etc/apache2/sites-enabled/default-ssl.conf`

```
sudo nano /etc/apache2/sites-enabled/default-ssl.conf
```

Add the same content as previously, and additionally write/uncoment the following lines

```
<IfModule mod_ssl.c>
  <VirtualHost _default_:443>
    ...
	  #   SSL Engine Switch:
		#   Enable/Disable SSL for this virtual host.
		SSLEngine on
		SSLProtocol all -SSLv2 -SSLv3 -TLSv1
		
		SSLCipherSuite "kEDH+AESGCM:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES256-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES256-GCMSHA384:ECDHE-RSA-AES256-GCM-SHA256:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-ECDSAAES256-SHA384:ECDHE-ECDSA-AES256-SHA256:ECDHE-ECDSA-AES256-SHA:ECDHE-ECDSAAES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA256:AES256-GCM-SHA384:!3DES:!DES:!DHE-RSA-AES128-GCM-SHA256:!DHE-RSA-AES256-SHA:!EDE3:!EDH-DSS-CBC-SHA:!EDH-DSSDES-CBC3-SHA:!EDH-RSA-DES-CBC-SHA:!EDH-RSA-DES-CBC3-SHA:!EXP-EDH-DSS-DES-CBCSHA:!EXP-EDH-RSA-DES-CBC-SHA:!EXPORT:!MD5:!PSK:!RC4-SHA:!aNULL:!eNULL"

		SSLHonorCipherOrder on

		# Disable SSL Compression
  		SSLCompression Off
  	
  	# Enable HTTP Strict Transport Security with a 2 year duration
 		Header always set Strict-Transport-Security "max-age=63072000;includeSubDomains"

		SSLCertificateFile	/root/certificates/sp.crt
		SSLCertificateKeyFile /root/certificates/sp.key

		#   Server Certificate Chain:
		#   Point SSLCertificateChainFile at a file containing the
		#   concatenation of PEM encoded CA certificates which form the
		#   certificate chain for the server certificate. Alternatively
		#   the referenced file can be the same as SSLCertificateFile
		#   when the CA certificates are directly appended to the server
		#   certificate for convinience.
		SSLCertificateChainFile /root/certificates/my-ca.crt

		#   Certificate Authority (CA):
		#   Set the CA certificate verification path where to find CA
		#   certificates for client authentication or alternatively one
		#   huge file containing all of them (file must be PEM encoded)
		#   Note: Inside SSLCACertificatePath you need hash symlinks
		#		 to point to the certificate files. Use the provided
		#		 Makefile to update the hash symlinks after changes.
		#SSLCACertificatePath /etc/ssl/certs/
    SSLCACertificateFile /root/certificates/my-ca.crt
    ...
	</VirtualHost>
</IfModule>
```

#### Insatll and configure Shibboleth


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

[1]: https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPApacheConfig
[keys]: https://github.com/jsbruglie/cripto/tree/dev/project/SP/keys
