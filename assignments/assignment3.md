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


The ``send()`` function will send packets at layer 3. It decides the routing based on local table.
The ``sendp()`` function will work at layer 2. 

Check the documentation for [scapy]. And this [guide]. And this [cheatsheet].

### 3. RST Hijacking

Check implementation in [rst_hijack.py]. 

You might want to know what are the flags you can use in ``sniff``, do this:

`` print sniff.__doc__ ``

### 4. Redirect response to ICMP echo/request 

Check implementation in [icmp_flood.py].

[assignment 2]: assignment2.md
[scapy]: http://scapy.readthedocs.io
[rst_hijack.py]: assignment3/rst_hijack.py
[icmp_flood.py]: assignment3/icmp_flood.py
[guide]: http://resources.infosecinstitute.com/scapy-all-in-one-networking-tool/
[cheatsheet]: https://blogs.sans.org/pen-testing/files/2016/04/ScapyCheatSheet_v0.2.pdf

