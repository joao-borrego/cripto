### Identity Provider configuration

Running [idp.sh](https://github.com/jsbruglie/cripto/blob/dev/project/IdP/idp.sh) and [copying the generated metadata](https://github.com/jsbruglie/cripto/tree/dev/project/IdP#copy-metadata) should setup everything as needed.

The configuration process is further detailed below.

#### Install dependencies

```
sudo apt update &&
sudo apt install vim \
default-jdk \
ca-certificates \
openssl \
tomcat8 \
apache2 \
ntp
```

#### Configure environment

Start a root terminal
```
sudo su -
```

Modify the host in `/etc/hosts`, replacing the entry with 127.0.1.1 by
```
127.0.1.1 idp.group9.csc.com idp
```

Define the environment variables for Java and IdP in `/etc/environment` by appending
```
JAVA_HOME="/usr/lib/jvm/java-8-openjdk-i386/jre"
IDP_SRC="/usr/local/src/shibboleth-identity-provider-3.2.1"
```

Export these variables to the current session
```
source /etc/environment &&
export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-i386/jre" &&
export IDP_SRC="/usr/local/src/shibboleth-identity-provider-3.2.1"
```

**Notice** that in an Ubuntu VM we install openjdk-**i386**.
On another scenario we may have to replace **i386** by **amd64**. 

#### Certificate and private key

To employ TLS, copy the pre-generated keys and certificates to /root/certificates and give them the following permissions.
The specifics are further detailed in [keys].

```
sudo mkdir -p /root/certificates
sudo cp keys/idp.crt /root/certificates/idp.crt
sudo cp keys/idp.key /root/certificates/idp.key
sudo cp keys/my-ca.crt /root/certificates/my-ca.crt
sudo chmod 0444 /root/certificates/idp.crt
sudo chmod 0755 /root/certificates/idp.key
sudo chmod 0444 /root/certificates/my-ca.crt
```

#### Configure Tomcat 8
```
update-alternatives --config java
update-alternatives --config javac
```
Edit `/etc/default/tomcat8`
```
JAVA_HOME=/usr/lib/jvm/java-8-openjdk-i386/jre
...
JAVA_OPTS="-Djava.awt.headless=true -XX:+DisableExplicitGC -XX:+UseParallelOldGC -Xms256m -Xmx2g -Djava.security.egd=file:/dev/./urandom"
```


#### Install Shibboleth Identity Provider v3.2.1

Launch a root terminal
```
sudo su -
```
Download Shibboleth IdP v3.2.1
```
cd /usr/local/src &&
wget http://shibboleth.net/downloads/identity-provider/3.2.1/shibboleth-identity-provider-3.2.1.tar.gz
&& tar -xzvf shibboleth-identity-provider-3.2.1.tar.gz
&& cd /usr/local/src/shibboleth-identity-provider-3.2.1
```
Run the installer
```
./bin/install.sh
```
When prompted, fill in the following in the required fields
```
Source (Distribution) Directory: [/usr/local/src/shibboleth-identity-provider-3.2.1]
Installation Directory: [/opt/shibboleth-idp]
Hostname: [localhost.localdomain]
idp.group9.csc.com
SAML EntityID: [https://idp.group9.csc.com/idp/shibboleth]
Attribute Scope: [localdomain]
group9.csc.com
Backchannel PKCS12 Password: inseguro
Re-enter password: inseguro
Cookie Encryption Key Password: inseguro
Re-enter password: inseguro
```

#### Install JST libraries 

This is for visualising the IdP status page.
```
cd /opt/shibboleth-idp/edit-webapp/WEB-INF/lib
wget https://build.shibboleth.net/nexus/service/local/repositories/thirdparty/content/javax/servlet/jstl/1.2/jstl-1.2.jar
cd /opt/shibboleth-idp/bin ; ./build.sh -Didp.target.dir=/opt/shibboleth-idp
```

#### Enable tomcat8 user's access to the required directories
```
chown -R tomcat8 /opt/shibboleth-idp/logs/ &&
chown -R tomcat8 /opt/shibboleth-idp/metadata/ &&
chown -R tomcat8 /opt/shibboleth-idp/credentials/ &&
chown -R tomcat8 /opt/shibboleth-idp/conf/
```

#### Configure SSL on Apache2

Edit the file `etc/apache2/sites-available/default-ssl.conf` as follows
```
<VirtualHost _default_:443>
  ServerName idp.group9.csc.com:443
  ServerAdmin admin@example.it
  DocumentRoot /var/www/html
  ...
  
  # Activate SSL
  SSLEngine On
  # Specify SSL protocols
  SSLProtocol all -SSLv2 -SSLv3 -TLSv1
  # Specify supported ciphers
  SSLCipherSuite "kEDH+AESGCM:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES256-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES256-GCMSHA384:ECDHE-RSA-AES256-GCM-SHA256:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-ECDSAAES256-SHA384:ECDHE-ECDSA-AES256-SHA256:ECDHE-ECDSA-AES256-SHA:ECDHE-ECDSAAES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA256:AES256-GCM-SHA384:!3DES:!DES:!DHE-RSA-AES128-GCM-SHA256:!DHE-RSA-AES256-SHA:!EDE3:!EDH-DSS-CBC-SHA:!EDH-DSSDES-CBC3-SHA:!EDH-RSA-DES-CBC-SHA:!EDH-RSA-DES-CBC3-SHA:!EXP-EDH-DSS-DES-CBCSHA:!EXP-EDH-RSA-DES-CBC-SHA:!EXPORT:!MD5:!PSK:!RC4-SHA:!aNULL:!eNULL"
  
  SSLHonorCipherOrder on
  
  # Disable SSL Compression
  SSLCompression Off
  # Enable HTTP Strict Transport Security with a 2 year duration
  Header always set Strict-Transport-Security "max-age=63072000;includeSubDomains"
  ...
  
  SSLCertificateFile /root/certificates/idp.crt
  SSLCertificateKeyFile /root/certificates/idp.key
  ...
</VirtualHost>
```

Configure Apache2 to open port 80 only for localhost ìn `/etc/apache2/ports.conf`
```
Listen 127.0.0.1:80
```

**Do not forget to copy the key and certificate** to `/root/certificates/` directory, if you haven't.

#### Enable SSL and headers modules for Apache2
```
a2enmod ssl headers &&
a2ensite default-ssl.conf &&
a2dissite 000-default.conf &&
systemctl reload apache2 &&
service apache2 restart 
```

#### Fix tomcat error [IMPORTANT] 

Tomcat may throw an exception claiming that some files were not found.
This can be easily fixed by creating symbolic links to these files in the same directory.
```
sudo ln -s /usr/share/java/tomcat8-jsp-api.jar /usr/share/java/jsp-api-2.3.jar
sudo ln -s /usr/share/java/tomcat8-el-api.jar /usr/share/java/el-api-3.0.jar
```

#### Configure Apache Tomcat 8

Edit `/etc/tomcat8/server.xml` and
1. Comment out the connector 8080 (HTTP) block
2. Enable the connector 8009 (AJP)
```
<!--
<Connector port="8080" protocol="HTTP/1.1"
           connectionTimeout="20000"
           URIEncoding="UTF-8"
           redirectPort="8443" />
-->
...
<!-- Define an AJP 1.3 Connector on port 8009 -->
<Connector port="8009" protocol="AJP/1.3"
           redirectPort="443" address="127.0.0.1"
           enableLookups="false" tomcatAuthentication="false"/>
```

Give it 640 permissions

```
sudo chmod 640 /etc/tomcat8/server.xml 
```

Create a file `/etc/tomcat8/Catalina/localhost/idp.xml` with
```
<Context docBase="/opt/shibboleth-idp/war/idp.war"
         privileged="true"
         antiResourceLocking="false"
         swallowOutput="true"/>
```

Create an Apache2 configuration file for IdP `/etc/apache2/sites-available/idp.conf` with 
```
<Proxy ajp://localhost:8009>
  Require all granted
</Proxy>

ProxyPass /idp ajp://localhost:8009/idp retry=5
ProxyPassReverse /idp ajp://localhost:8009/idp retry=5
```

Modify `/etc/tomcat8/context.xml` to prevent a *lack of persistence of the session objects* error
and uncomment the line
```
<Manager pathname="" />
```

Give it 640 permissions

```
sudo chmod 640 /etc/tomcat8/context.xml
```

Enable **proxy_ajp** apache2 module and the IdP site.
```
a2enmod proxy_ajp ; a2ensite idp.conf ; service apache2 restart
```

Verify that the IdP is working by opening on your browser at `https://localhost/idp/shibboleth`.
If it does not, restart the machine and retry.
You should be able to see an XML metadata file.

#### Configure htpasswd for authentication

We will use Apache's `htpasswd` for authenticating users.

Create a directory at `/usr/local/idp/credentials`
```
sudo mkdir /usr/local/idp/credentials -p
```

Add a new user to a new credentials database.
```
htpasswd -c /usr/local/idp/credentials/user.db user
# Supply password inseguro and confirm
```

Protect to the remote authentication resource in `/etc/apache2/sites-available/idp.conf`
```
<Location /idp/Authn/RemoteUser>
    AuthType Basic
    AuthName "Group 9 IdP"
    AuthUserFile /usr/local/idp/credentials/user.db
    require valid-user
</Location>
```

Define the authentication flow by editing the file `/opt/shibboleth-idp/conf/idp.properties` in the following line.

```
idp.authn.flows= Password|RemoteUser
```

#### Provide the metadata path

Edit the file `/opt/shibboleth-idp/conf/metadata-providers.xml` at the bottom with the following.

```
<MetadataProvider id="LocalMetadata" xsi:type="FilesystemMetadataProvider" metadataFile="/opt/shibboleth-idp/conf/sp-metadata.xml"/> 
```

#### Copy metadata

Go to `https://idp.group9.csc.com/idp/shibboleth` and save the content to a file named `idp-metadata.xml`.

Next: [Metadata](https://github.com/jsbruglie/cripto/tree/dev/project#6-metadata)


### References

1. [Shibboleth IdP Tutorial][1] by `malavolti`, as of 22-01-2018
2. [Shibboleth IdP Official Documentation][2], as of 22-01-2018


[keys]: keys/README.md

[1]: https://github.com/malavolti/HOWTO-Install-and-Configure-Shibboleth-Identity-Provider
[2]: https://wiki.shibboleth.net/confluence/display/SHIB2/IdPConfiguration
