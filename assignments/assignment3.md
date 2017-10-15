## Assignment 3 - Using Scapy

### 2. Testing scapy

Repeat the ARP table attack from [Assignment 2], but using scapy instead of nemesis.
On machine 2 obtain the MAC addresses of machines 1 and 2, and **edit the device ID `devID` of the network adapter in the python script**.
If you fail to do this, the program is likely to crash.
```
mac_1=[MAC machine 1] &&
mac_2=[MAC machine 2] &&
cd csc-course/assignment3 &&
sudo python arpp.py -S 192.168.1.3 -D 192.168.1.1 -h $mac_2 -m $mac_1
```

If succesful, the ARP table of machine 1 will now have a spoofed MAC address for machine 3.

Check the documentation for [scapy].

### 3. RST Hijacking

TODO

### 4. Redirect response to ICMP echo/request 

TODO

[assignment 2]: assignment2.md
[scapy]: http://scapy.readthedocs.io