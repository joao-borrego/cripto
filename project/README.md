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
The DNS folder must be copied to the same directory as the configuration script.
Alternatively, just clone the repository to your home folder.













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