### Service Provider configuration

Running [sp.sh](https://github.com/jsbruglie/cripto/blob/dev/project/SP/sp.sh) and [copying the generated metadata](https://github.com/jsbruglie/cripto/tree/dev/project/SP#copy-metadata) should setup everything as needed.


The configuration process is further detailed below.

#### Install Apache 

To implement the SP, we need a web server, since half of Shibboleth runs within it.
Furthermore, our SP will be the host for the protected resource.
For that, we will be using Apache.

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
sudo cp keys/sp.crt /root/certificates/sp.crt
sudo cp keys/sp.key /root/certificates/sp.key
sudo cp keys/my-ca.crt /root/certificates/my-ca.crt
sudo cp keys/my-ca.key /root/certificates/my-ca.key
sudo chmod 0755 /root/certificates/sp.crt
sudo chmod 0755 /root/certificates/sp.key
sudo chmod 0755 /root/certificates/my-ca.crt
sudo chmod 0755 /root/certificates/my-ca.key
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

`Redirect` blocks non-SSL access, redirecting an HTTP request to a HTTPS one. This is **very important**, refer to [Notes].

```
 <Location /resource/>
        AuthType shibboleth
        ShibRequestSetting requireSession 1
        Require valid-user
</Location>
```
Sets up apache to enable shibboleth. The two generic commands around the middle one are Apache's way of signaling that you want the module to run, and that any authenticated user is acceptable. The middle setting tells the SP to perform authentication any time a session isn't already in place, which ensures that the authorization rule can be met [[1]].

##### For HTTPS

Now we will do the same for HTTPS requests, but also define the configuration for the SSL module. Edit the `/etc/apache2/sites-enabled/default-ssl.conf`.

```
sudo nano /etc/apache2/sites-enabled/default-ssl.conf
```

Add the same content as previously at the beggining of the file and additionally write/uncoment the following lines

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

```
sudo apt install libapache2-mod-shib2 -y 
```

Set up a Shibboleth certificate (this is different to the Apache certicate)

```
sudo shib-keygen -h sp.group9.csc.com -f
```

Edit `/etc/shibboleth/shibboleth2.xml`. 

```
sudo nano /etc/shibboleth/shibboleth2.xml
```

Edit the `ApplicationDefaults` element to include the entityID of the Service Provider.

```
 <ApplicationDefaults entityID="https://sp.group9.csc.com/shibboleth"
REMOTE_USER="eppn persistent-id targeted-id">
```

Edit the `Sessions` element to use SSL.

```
<Sessions lifetime="28800" timeout="3600" relayState="ss:mem"
checkAddress="false" handlerSSL="true" cookieProps="https">
```

Configure the SSO for a default IdP (this could be set to use more than one IdP, by setting a WAYF discovery service).

```
<SSO entityID="https://idp.group9.csc.com/idp/shibboleth">
              SAML2 SAML1
</SSO>
```

Set an appropriate support contact in the `Errors` element. [Optional]

```
 <Errors supportContact="support@group9.csc.com"
            helpLocation="/about.html"
styleSheet="/shibboleth-sp/main.css"/>
```

Add a `MetadataProvider` element.

```
 <MetadataProvider type="XML" validate="true" file="idp-metadata.xml"/>
```

This was setup according to [[2]].


#### Activate and deavtivate apache modules 

```
sudo a2enmod ssl headers &&
sudo a2enmod shib2 &&
sudo a2ensite group9.csc.com.conf &&
sudo a2ensite default-ssl.conf &&
sudo a2dissite 000-default.conf &&
sudo systemctl reload apache2 &&
sudo service apache2 restart
```

#### Restart the services

```
sudo /etc/init.d/shibd restart
sudo /etc/init.d/apache2 restart
```

#### Copy metadata

Go to `https://sp.group9.csc.com/Shibboleth.sso/Metadata` and save the content to a file named `sp-metadata.xml`. 

#### Notes

- Because we are using the "secure" cookie attribute to limit cookie use to SSL-protected requests (`cookieProps="https"` in shibboleth2.xml `Sessions` element), which is highly advisable for any site intended to be SSL protected, the HTTP and HTTPS requests will bounce between each other it non-SSL access isn't blocked [[3]]. This was accomplished with the `Redirect` field on `group9.csc.com.conf`.

- According to the official documentation of Shibboleth the access resctriction to the protected resource can be set using the `RequestMapper` element in shibboleth2.xml. But because we are using apache as a web server, this **will not** work due to Apache's interal design [[1]], thus enabling the shibboleth module on apache virtual hosts config files.


Next: [IdP]

### References

1. [Shibboleth Native SP for Apache Official Documentation][1], as of 22-01-2018
1. [University of Oxford's Installation Guide for Shibboleth SP with Apache][2], as of 22-01-2018
1. [Shibboleth Native SP Looping][3], as of 22-01-2018

[1]: https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPApacheConfig
[2]: https://help.it.ox.ac.uk/iam/federation/shibsp-apache-howto
[3]: https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPLooping
[keys]: https://github.com/jsbruglie/cripto/tree/dev/project/SP/keys
[Notes]: https://github.com/jsbruglie/cripto/blob/dev/project/SP/README.md#notes
[IdP]: https://github.com/jsbruglie/cripto/blob/dev/project/IdP/README.md
