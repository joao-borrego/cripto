## IdP Setup


### Installation

Start by cloning the tutorial repository to `usr/local/src`
```
sudo git clone https://github.com/malavolti/HOWTO-Install-and-Configure-Shibboleth-Identity-Provider.git /usr/local/src/HOWTO-Shib-IdP
```

Install dependencies
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

### Configure environment

Start a root terminal
```
sudo su -
```

Modify the host in `/etc/hosts`, replacing the entry with 127.0.1.1 by
```
127.0.1.1 idp.example.org idp
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

Generate self-signed key and certificate
```
openssl req -x509 -newkey rsa:4096 -keyout /root/certificates/idpkey-server.key -out /root/certificates/idp-cert-server.crt -nodes -days 3650
```
Fill the required fields as follows
```
Country Name (2 letter code) [AU]:PT
State or Province Name (full name) [Some-State]:Lisbon
Locality Name (eg, city) []:Lisbon
Organization Name (eg, company) [Internet Widgits Pty Ltd]:CSC-9
Organizational Unit Name (eg, section) []:CA-9
Common Name (e.g. server FQDN or YOUR name) []:CA9
Email Address []:email@address.pt
```

Configure Tomcat 8
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


### Install Shibboleth Identity Provider v3.2.1

Launch a root terminal
```
sudo su -
```

Download Shibboleth IdP v3.2.1
```
cd /usr/local/src &&
wget http://shibboleth.net/downloads/identity-provider/3.2.1/shibboleth-identity-provider-3.2.1.tar.gz
&& tar -xzvf shibboleth-identity-provider-3.2.1.tar.gz
&& cd shibboleth-identity-provider-3.2.1
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
idp.example.it
SAML EntityID: [https://idp.example.it/idp/shibboleth]
Attribute Scope: [localdomain]
example.it
Backchannel PKCS12 Password: back_pass
Re-enter password: back_pass
Cookie Encryption Key Password: crypt_pass
Re-enter password: crypt_pass
```

Install JST libraries in order to visualise the IdP status page
```
cd /opt/shibboleth-idp/edit-webapp/WEB-INF/lib
wget https://build.shibboleth.net/nexus/service/local/repositories/thirdparty/content/javax/servlet/jstl/1.2/jstl-1.2.jar
cd /opt/shibboleth-idp/bin ; ./build.sh -Didp.target.dir=/opt/shibboleth-idp
```

Enable **tomcat8** user's access to the required directories
```
chown -R tomcat8 /opt/shibboleth-idp/logs/ &&
chown -R tomcat8 /opt/shibboleth-idp/metadata/ &&
chown -R tomcat8 /opt/shibboleth-idp/credentials/ &&
chown -R tomcat8 /opt/shibboleth-idp/conf/
```