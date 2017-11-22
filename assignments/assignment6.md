## Assignment 6 - Public Key Cryptography

- [1. Introduction](#1-introduction)
- [2. Setup](#2-setup)
- [3. HTTPS Secure Connections](#3-https-secure-connections)
  * [3.1 Creating a certification entity](#31-creating-a-certification-entity)
  * [3.2 Creating a certificate for the web server](#32-creating-a-certificate-for-the-web-server)


### 1. Introduction

A certification authority (CA) is an entity that issues digital certificates, which validate the ownership of a public key using a given name.
This allows others to rely on these signatures to identify entities in communications.
Essentially it tackles the man-in-the-middle attack.
The CA acts as a trusted third party, that allows the authentication of the involved agents.

### 2. Setup

We will use the network described in Assignment 4, except machine 4 will not be needed.
The remaining 3 machines wil each play one of the following roles
- Web client - machine 1
- Web server - machine 2
- Certification authority - machine 3

### 3. HTTPS Secure Connections

HTTPS builds upon the specification of HTTP to add secure communication.
In HTTPS the communication protocol is encrytped using Transport Layer Security (TLS) or its predecessor Secure Sockets Layer (SSL).
It provides a way to authenticate the accessed website and ensures data privacy and integrity, through means of cryptography.

#### 3.1 Creating a certification entity

On machine 3 run 

```
sudo -i
mkdir /root/CA
chmod 0770 /root/CA
cd /root/CA
```

Public key (or asymmetrical) criptography relies on the use of a pair of public and private keys.
It simultaneously  accomplishes authentication and encryption:
    - The public key is used to verify the identity of the server (using a CA).
    - Anyone can encrypt messages with the public key, but only the receiver can decode them using the private key.

Generate a key pair for 2048-bit RSA cipher algorithm with the symmetric cipher algorithm 3DES (Triple DES) and a user-provided password (`inseguro`).
This will be the public and private key for the certification authority.

```
openssl genrsa -des3 -out my-ca.key 2048
```

After the keys have been generated it is necessary to sign the public key with the CA's private key.
This is a root-certificate (i.e. self-signed) the private signature key is the public key pair to be signed.
A self-signed certificate is similar to a certificate signing request (CSR), which is a solicitaion of a digital identity certificate from a certificate authority.
For this reason we use the same `req` command.
However, the `x509` utility is used to generate the certificate itself.

```
openssl req -new -x509 -days 3650 -key my-ca.key -out my-ca.crt
# Enter previously chosen passphrase
Country Name (2 letter code) [AU]: PT
State or Province Name (full name) [Some-State]: Lisbon
Locality Name (eg, city) []: Lisbon
Organization Name (eg, company) [Internet Widgits Pty Ltd]: CSC-9
Organizational Unit Name (eg, section) []: CA-9
Common Name (e.g. server FQDN or YOUR name) []: CA9
Email Address []: email@address.pt
```
To view the contents of your CA certificate you can run

```
openssl x509 -in my-ca.crt -text 2>&1 | less
```

2>&1 merges `stderr (2)` with `stdout (1)`, thus surpressing possible invalid permission errors

### 3.2 Creating a certificate for the web server
