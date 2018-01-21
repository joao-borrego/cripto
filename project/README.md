## Project - SAML2.0 Federation

 * [1. Introduction](#1-introduction)
 * [2. Setup](#2-setup)
 * [3. DNS](#3-dns)
 * [4. SP](#4-sp)
 * [5. IdP](#5-idp)
 * [6. Metadata](#6-metadata)
 * [Notes](#notes)

### 1. Introduction

Our goal is to create a SAML2.0 federation.
Security Assertion Markup Language (SAML) is an open standard for authentication and authorisation purposes.
It consists of an XML-based markup language typically used between an identity provider and a service provider.

The intended setup is a small SAML federation with only 3 entities:

1. Service Provider (SP)
2. Server Client (Browser) 
3. Indentity Provider (IdP)


Each of the aforementioned entities will run on a dedicated virtual machine.
They will be connected by an internal virtual network.
The process of achieving this can be mostly automated, assuming a clean install environment.
For this reason we have written scripts to automatically install required dependencies or copy pre-filled configuration files, which was useful for testing purposes and ensuring that the process could be replicated.

### 2. Setup

The process of creation and configuration of the virtual machine and respective communication setup is further detailed in [Setup].

### 3. DNS

Each entity in our federation must be identified by a name.
We describe the process of installing a Domain Name Server in [DNS].

### 4. SP

The service provider receives and accepts authentication assertions.
Our objective is to have a protecetd resource hosted in a given web server.
In this case, this will also be hosted in the SP machine.
Whenever a client tries to access this private resource, the SP will redirect the user to the IdP for authentication.
Afterwards, a sucessfully authenticated user will then reply to the SP and the resource will be supplied.
The figure below illustrates the message flow [[1]].

<p align="center"> 
	<img src=images/saml_flow.gif>
</p>

The configuration of the SP is further detailed in [SP].

### 5. IdP

The identity provider issues authentication assertions in order to authenticate a given entity.
Our setup will use Apache's `htpasswd` utility to authenticate a client trying to access the protected resource in SP.
If the assertion suceeds, the user is redirected to the SP.

We should mention that communications employ TLS and as such require certificates to be issued in order to establish a trust relationship between client and server.
In our scenario, th IdP will simultaneously behave as the Certification Authority (CA), which signs the public keys of both SP and IdP in order to generate the required certificates.

The configuration of the IdP is further detailed in [IdP].

### 6. Metadata

In order for the SP and IdP to be able to communicate with each other, it is of utmost importance that each service is recognised and verified.
This essentially means that each of them must have access to the other's **metadata**.
In our scenario, it suffices that each entity has the other's metadata XML file in a known and accessible directory.
If these files are missing or outdated, it is very likely that the system **will fail**!

### Notes

#### Paswords and passphrases

Since this project is merely a proof-of-concept implementation, whenever we were asked to provide a passphrase or password we always set it to `inseguro` (which stands for *unsafe* in portuguese, in a jokingly self-aware fashion).


#### Prevent automatic log-off in Lubuntu

Prevent virtual machine from auto-logging off by editing `/usr/share/lightdm/lightdm.conf.d/20-lubuntu.conf` to resemble

```
[Seat:*]
user-session=Lubuntu
[SeatDefaults]
autologin-user=user
autologin-user-timeout=0
```

[Setup]: setup/README.md
[DNS]: DNS/README.md
[SP]: SP/README.md
[IdP]: IdP/README.md

[1]: http://docs.oasis-open.org/security/saml/Post2.0/sstc-saml-tech-overview-2.0-cd-02.html#5.1.Web
