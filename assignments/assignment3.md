## Assignment 3 - Using Scapy

 * [2. Testing Scapy](#2-testing-scapy)
 * [3. RST Hijacking](#3-rst-hijacking)
 * [4. Redirect response to ICMP echo/request](#4-redirect-response-to-icmp-echorequest)

### 2. Testing scapy

Repeat the ARP table attack from [Assignment 2], but using scapy instead of nemesis.
On machine 2 obtain the MAC addresses of machines 1 and 2.

```
cd csc-course/assignment3 &&
sudo python arpp.py -S 192.168.1.3 -D 192.168.1.1 -h <MAC machine 2> -m <MAC machine 1> -i enp0s3
```

If succesful, the ARP table of machine 1 will now have a spoofed MAC address for machine 3.

The python script achieves this with the following command:
```
sendp(Ether(dst=dstMAC, src=srcMAC)/ARP(hwsrc=srcMAC, hwdst=dstMAC, psrc=srcIP, pdst=dstIP), iface=devID)
```

Scapy allows us to create our own packets, namely stacking different protocol layers.
The previous command is sending an ARP Ethernet packet.
To do so, it relies on the composition operator `/` to stack the Ethernet and ARP layers.

Check the documentation for [scapy].

### 3. RST Hijacking

TODO

### 4. Redirect response to ICMP echo/request 

TODO

[assignment 2]: assignment2.md
[scapy]: http://scapy.readthedocs.io