# Change config files permission
# -rw-r--r--
sudo chmod 644 configs/* 

# Tutorial Repo
sudo git clone https://github.com/malavolti/HOWTO-Install-and-Configure-Shibboleth-Identity-Provider.git /usr/local/src/HOWTO-Shib-IdP

# Dependencies
sudo apt -qq update
sudo apt install vim default-jdk ca-certificates openssl tomcat8 apache2 ntp

# Environment variables setup
sudo cp configs/hosts /etc/hosts
sudo cp configs/environment /etc/environment

# Certificate and private key
sudo mkdir /root/certificates
sudo cp configs/idp-cert-server.crt /root/certificates/idp-cert-server.crt
sudo cp configs/idp-key-server.key /root/certificates/idp-key-server.key
sudo chmod 0755 /root/certificates/idp-cert-server.crt
sudo chmod 0755 /root/certificates/idp-key-server.crt

# Configure Tomcat 8
update-alternatives --config java
update-alternatives --config javac
sudo cp configs/tomcat8 /etc/default/tomcat8

# Install Shibboleth

# Download and unpack
sudo wget http://shibboleth.net/downloads/identity-provider/3.2.1/shibboleth-identity-provider-3.2.1.tar.gz -nc -P /usr/local/src
sudo tar -xzf /usr/local/src/shibboleth-identity-provider-3.2.1.tar.gz -C /usr/local/src
# Install
printf "\n[TUTORIAL] Install Shibboleth\n\n"
printf "\tSource (Distribution) Directory: [/usr/local/src/shibboleth-identity-provider-3.2.1]\n\
	Installation Directory: [/opt/shibboleth-idp]\n\
	Hostname: [localhost.localdomain] idp.example.it\n\
	SAML EntityID: [https://idp.example.it/idp/shibboleth]\n\
	Attribute Scope: [localdomain] example.it\n\
	Backchannel PKCS12 Password: back_pass\n\
	Cookie Encryption Key Password: crypt_pass\n\n"

sudo bash /usr/local/src/shibboleth-identity-provider-3.2.1/bin/install.sh
# Install JST libraries
sudo wget https://build.shibboleth.net/nexus/service/local/repositories/thirdparty/content/javax/servlet/jstl/1.2/jstl-1.2.jar -P /opt/shibboleth-idp/edit-webapp/WEB-INF/lib -nc
sudo bash /opt/shibboleth-idp/bin/build.sh -Didp.target.dir=/opt/shibboleth-idp
# Enable tomcat8 access
sudo chown -R tomcat8 /opt/shibboleth-idp/logs/
sudo chown -R tomcat8 /opt/shibboleth-idp/metadata/
sudo chown -R tomcat8 /opt/shibboleth-idp/credentials/
sudo chown -R tomcat8 /opt/shibboleth-idp/conf/
# Enable SSL and headers modules for Apache2
sudo a2enmod ssl headers &&
sudo a2ensite default-ssl.conf &&
sudo a2dissite 000-default.conf &&
sudo systemctl reload apache2 &&
sudo service apache2 restart 

# Configuration

# SSL on Apache2
sudo cp configs/default-ssl.conf /etc/apache2/sites-available/default-ssl.conf
sudo cp configs/ports.conf /etc/apache2/ports.conf
# Tomcat 8
sudo cp configs/server.xml /etc/tomcat8/server.xml
sudo chmod 640 /etc/tomcat8/server.xml 
sudo cp configs/idp.xml /etc/tomcat8/Catalina/localhost/idp.xml
sudo cp configs/idp.conf /etc/apache2/sites-available/idp.conf
sudo cp configs/context.xml /etc/tomcat8/context.xml
sudo chmod 640 /etc/tomcat8/context.xml
# Enable proxy_ajp
sudo a2enmod proxy_ajp ; sudo a2ensite idp.conf ; sudo service apache2 restart

# Install MySQL Connector Java and Tomcat JDBC libraries
sudo apt-get install mysql-server libmysql-java &&
sudo cp /usr/share/java/mysql-connector-java.jar /opt/shibboleth-idp/edit-webapp/WEB-INF/lib/ &&
sudo cp /usr/share/java/mysql-connector-java.jar /usr/share/tomcat8/lib/ &&
sudo cp /usr/share/tomcat8/lib/tomcat-jdbc.jar /opt/shibboleth-idp/edit-webapp/WEB-INF/lib/

# Install Common DBCP2 libraries
sudo wget https://archive.apache.org/dist/commons/dbcp/binaries/commons-dbcp2-2.1.1-bin.tar.gz -P /usr/local/src -nc &&
sudo tar xzv /usr/local/src/commons-dbcp2-2.1.1-bin.tar.gz -C /usr/local/src  &&
sudo cp /usr/local/src/commons-dbcp2-2.1.1/commons-dbcp2-2.1.1.jar /opt/shibboleth-idp/edit-webapp/WEB-INF/lib/commons-dbcp2-2.1.1.jar

# Install Tomcat Common Pool
sudo wget https://archive.apache.org/dist/commons/pool/binaries/commons-pool2-2.4.2-bin.tar.gz -P /usr/local/src -nc &&
sudo tar xzf /usr/local/src/commons-pool2-2.4.2-bin.tar.gz -C /usr/local/src  &&
sudo cp /usr/local/src/commons-pool2-2.4.2/commons-pool2-2.4.2.jar /opt/shibboleth-idp/edit-webapp/WEB-INF/lib/commons-pool2-2.4.2.jar

# Rebuild idp.war
sudo bash /opt/shibboleth-idp/bin/build.sh

# Create shibboleth user in MySQL DB
sudo mysql -u root < configs/shibboleth-db.sql &&
sudo service mysql restart

# Enable the generation of the persistent-id
sudo cp configs/saml-nameid.properties /opt/shibboleth-idp/conf/saml-nameid.properties
# Enable the SAML2PersistentGenerator
sudo cp configs/saml-nameid.xml /opt/shibboleth-idp/conf/saml-nameid.xml
sudo cp configs/subject-c14n.xml /opt/shibboleth-idp/conf/c14n/subject-c14n.xml
# Enable JPAStorageService
sudo cp configs/global.xml /opt/shibboleth-idp/conf/global.xml
sudo cp configs/idp.properties /opt/shibboleth-idp/conf/idp.properties


# Set permissions on config files
# -rw-rw-rw-
sudo chmod 666 configs/*
