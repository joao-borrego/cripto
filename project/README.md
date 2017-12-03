## Project - SAML2.0 Federation

 * [1. Introduction](#1-introduction)
 * [2. Setup](#2-setup)
 * [3. DNS](#3-dns)

### 1. Introduction

### 2. Setup

Start by creating the required virtual machines by running [vbox.sh].
We will use 5 different machines:

- Service Provider (SP)
- Browser
- Identity Provider 1 (IdP1)
- WAYF (Where Are You From)
- Identity Provider 2 (IdP2)

Each of the machines has to be configured internally.
For this, run the [configuration script] in every machine.

### 3. DNS

The SP machine was chosen to be the domain name server in the network.
Copy the DNS folder to the project's root directory.
Running the configuration file should setup everything as needed.
The configuration process can be briefly described as follows

- Install BIND service and configure it to IPv4 mode
- Configure DNS options in `named.conf.options` file
    - Add machines to acl (Access Control List) trusted block
    - Configure options block in order to
        - allow recursive queries from "trusted" clients
        - listen on private networks (using eth0, IP 192.168.1.1)
        - disable zone transfers by default
- Configure local options in `named.conf.local` file
    - Add the forward zone "group9.csc.com"
    - Add the reverse zone "168.192.in-addr.arpa" (note the octet reversal of 192.168)
- Create forward zone file in `/etc/bind/zones/db.group9.csc.com`
- Create reverse zone file in `/etc/bind/zones/db.192.168`
- Restart BIND










### Extras

Prevent virtual machine from auto-logging off by editing `/usr/share/lightdm/lightdm.conf.d/20-lubuntu.conf` to resemble

```
[Seat:*]
user-session=Lubuntu
[SeatDefaults]
autologin-user=user
autologin-user-timeout=0
```

[vbox.sh]: vbox.sh
[configuration script]: configs.sh