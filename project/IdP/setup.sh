# Tutorial Repo
sudo git clone https://github.com/malavolti/HOWTO-Install-and-Configure-Shibboleth-Identity-Provider.git /usr/local/src/HOWTO-Shib-IdP &&

# Dependencies
sudo apt update
sudo apt install vim default-jdk ca-certificates openssl tomcat8 apache2 ntp

# Environment variables setup
sudo cp configs/hosts /etc/hosts
sudo cp configs/environment /etc/environment

# Certificate and private key
sudo mkdir /root/certficates
sudo cp configs/idp-cert-server.crt /root/certficates/idp-cert-server.crt
sudo cp configs/idp-key-server.key /root/certficates/idp-key-server.crt

# Configure Tomcat 8
update-alternatives --config java
update-alternatives --config javac
sudo cp configs/tomcat8  /etc/default/tomcat8

# Install Shibboleth

# Download and unpack
sudo cd /usr/local/src
sudo wget http://shibboleth.net/downloads/identity-provider/3.2.1/shibboleth-identity-provider-3.2.1.tar.gz
sudo tar -xzvf shibboleth-identity-provider-3.2.1.tar.gz
sudo cd shibboleth-identity-provider-3.2.1
# Install
echo "Check tutorial and fill the fields accordingly."
sudo ./bin/install.sh
# Install JST libraries
sudo cd /opt/shibboleth-idp/edit-webapp/WEB-INF/lib
sudo wget https://build.shibboleth.net/nexus/service/local/repositories/thirdparty/content/javax/servlet/jstl/1.2/jstl-1.2.jar
sudo cd /opt/shibboleth-idp/bin ; sudo ./build.sh -Didp.target.dir=/opt/shibboleth-idp
# Enable tomcat8 access
sudo chown -R tomcat8 /opt/shibboleth-idp/logs/
sudo chown -R tomcat8 /opt/shibboleth-idp/metadata/
sudo chown -R tomcat8 /opt/shibboleth-idp/credentials/
sudo chown -R tomcat8 /opt/shibboleth-idp/conf/

# Configuration

# SSL on Apache2
sudo cp configs/default-ssl.conf etc/apache2/sites-available/default-ssl.conf
sudo cp configs/ports.conf /etc/apache2/ports.conf
# Tomcat 8
sudo cp configs/server.xml /etc/tomcat8/server.xml
sudo cp configs/idp.xml /etc/tomcat8/Catalina/localhost/idp.xml
sudo cp configs/idp.conf /etc/apache2/sites-available/idp.conf
sudo cp configs/context.xml /etc/tomcat8/context.xml