;
; BIND data file for local loopback interface
;
$TTL	604800
@	IN	SOA	group9.csc.com. admin.group9.csc.com. (
			      3		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			 604800 )	; Negative Cache TTL
;

; name servers - NS records
	IN	NS	ns1.group9.csc.com.

; name servers - A records
ns1.group9.csc.com.	IN	A	192.168.1.1

; 192.168.0.0/16 - A records
browser.group9.csc.com.	IN	A	192.168.1.2
inp1.group9.csc.com.	IN	A	192.168.1.3
wayp.group9.csc.com.	IN	A	192.168.1.4
inp2.group9.csc.com.	IN	A	192.168.1.5