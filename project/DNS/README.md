### Domain Name Server Setup

Our setup requires an internal DNS, so each machine can be easily identified.
The SP machine was chosen to be the domain name server in the network.
Running [dns.sh][dns.sh] from our repository's DNS directory should setup everything as needed.
The goal is to have the following correspondence

| Machine | DNS Role | intnet1 IP  | Name                   |
|---------|----------|-------------|------------------------|
| SP      | Server   | 192.168.1.1 | sp.group9.csc.com      |
| Browser | Client   | 192.168.1.2 | browser.group9.csc.com |
| IdP     | Client   | 192.168.1.3 | idp.group9.csc.com     |

The configuration process is further detailed below.

#### Server

Stary by installing the BIND service in **SP**.
```
sudo apt install bind9 bind9utils bind9-doc
```

Set BIND to IPV4 mode by editing `/etc/default/bind9` and add **-4** to `OPTIONS`
```
OPTIONS="-4 -u bind"
```

Then edit `/etc/bind/named.conf.options` and add a list of clients which will be allowed to perform recursive DNS queries.
```
acl "trusted" {
	192.168.1.1;	# SP
	192.168.1.2;	# Browser
	192.168.1.3;	# IdP
};
```
Now, configure the `options` block below, in order to enable listening to the internal network and disable zone transfers.
The latter are used to replicate DNS databases across servers, which we will not require.
```
options {
	directory "/var/cache/bind";

	recursion yes;
	allow-recursion { trusted; };
	listen-on { 192.168.1.1; };
	allow-transfer { none; };

	forwarders {
		8.8.4.4;
		8.8.8.8;
	};
...
```

Now, we must configure the forward and reverse zones by editing `/etc/bind/named.conf.local`.
```
zone "group9.csc.com" {
	type master;
	file "/etc/bind/zones/db.group9.csc.com";
};

zone "168.192.in-addr.arpa" {
	type master;
	file "/etc/bind/zones/db.192.168";
};
```
Note the octet reversal in the reverse zone (168.192)

Create each of the zone files.
Start by creating the directory `/etc/bind/zones`.
Create and edit the forward zone file `/etc/bind/zones/db.group9.csc.com`
```
$TTL	604800
@	IN	SOA	sp.group9.csc.com. admin.group9.csc.com. (
			      3		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			 604800 )	; Negative Cache TTL
;

; name servers - NS records
	IN	NS	sp.group9.csc.com.

; name servers - A records
sp.group9.csc.com.		IN	A	192.168.1.1

; 192.168.0.0/16 - A records
browser.group9.csc.com.		IN	A	192.168.1.2
idp.group9.csc.com.		IN	A	192.168.1.3
```

Create and edit the reverse zone file `/etc/bind/zones/db.192.168`
```
$TTL	604800
@	IN	SOA	sp.group9.csc.com. admin.group9.csc.com. (
			      3		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			 604800 )	; Negative Cache TTL
;

; name servers
	IN	NS	sp.group9.csc.com.

; PTR Records
1.1	IN	PTR	sp.group9.csc.com.	; 192.168.1.1
2.1	IN	PTR	browser.group9.csc.com.	; 192.168.1.2
3.1	IN	PTR	idp.group9.csc.com.	; 192.168.1.3
```

Finally, restart BIND with
```
sudo service bind9 restart
```

#### Clients

Each Ubuntu/Debian client must edit `/etc/resolvconf/resolv.conf.d/head` file and add
```
search group9.csc.com
nameserver 192.168.1.1
```

Then, they must generate a new configuration by running
```
sudo resolvconf -u
```

Next: [SP](https://github.com/jsbruglie/cripto/blob/dev/project/README.md#4-sp)

[dns.sh]: dns.sh
