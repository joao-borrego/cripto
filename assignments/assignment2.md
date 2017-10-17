## Assignment 2

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

Tcpdump prints the contents of network packets. With the necessary privileges on a system through which unencrypted traffic such as Telnet or HTTP passes, a user can use tcpdump to view login IDs, passwords, the URLs and content of websites being viewed, or any other unencrypted information. Here's a nice [tutorial](https://danielmiessler.com/study/tcpdump/) and [usage examples](https://www.rationallyparanoid.com/articles/tcpdump.html).

Run `sudo tcpdump` on machine 3, and generate a ICMP packet from machine 1 to 2 using

```
ping -c 1 192.168.1.2 # The count option set to 1 generates a single packet
```

The output should resemble:
```
17:07:30.455566 IP machine1 > machine2: ICMP echo request, id 2701, seq 1, length 64
17:07:30.455664 IP machine2 > machine1: ICMP echo reply, id 2701, seq 1, length 64
```

The `-X` option prints each packet in HEX and ASCII minus its link level header. The `-XX` option prints each packet in HEX and ASCII including its link level header (AKA ethernet header). Inside the HEX dump output is the destination and source MAC addresses. 


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

Here you can check the Ethernet, IP and TCP headers in ASCII:

![alt text](https://github.com/jsbruglie/cripto/tree/dev/assignments/.images/wireshark_hexdump.png "Hexdump")

However, if we establish an ssh connection between 1 and 2, Wireshark will detect the Diffie-Hellman key exchange,
but will be unable to decypher the content of the folowing ecnrypted packets.

#### 1.4 `nmap`

Nmap is a utility tht provides information on remote machines.
Issuing `nmap [IP]` should return a list of open ports on the destination machine.
`sudo nmap -O [IP]` should return the OS running on the destination machine. 

### 2. Vulnerabilities in TCP/IP

#### 2.1 ARP redirect

Machine 2 will be the attacker. Start by obtaining the MAC addresses of 1 and 3.
```
ping -c 1 192.168.1.1 # 08:00:27:4b:d6:a2
ping -c 1 192.168.1.3 # 08:00:27:90:f9:41
```
Check the MAC address of the attacking machine with 
```
ifconfig # ... ether 08:00:27:94:55:1f
```

You can check the contents of the arp table in machine 1 with `arp -a #all`.
Now, use `nemesis` in machine 2 to attack the arp table in 1.

```
sudo nemesis arp -v -S 192.168.1.3 -D 192.168.1.1 -h [MAC machine 2] -m [MAC machine 1]
```

This should effectively fool machine 1 into thinking that machine3 has the MAC of 2, thus redirecting packets to it.
We can check the attack was succesful by checking the arp table in 1, which can resemble.
```
machine3 (192.168.1.3) at 08:00:27:94:55:1f [ether] on enp0s8
machine2 (192.168.1.2) at 08:00:27:94:55:1f [ether] on enp0s8
```
Notice how the MAC address is the same for both machines.

#### 2.2 RST Hijacking

TODO
I could not get this thing to work. Pls help

#### 2.3 Redirect response to ICMP echo/request

TODO

### 3. OpenVAS
Open the browser in `localhost` on the machine with openVAS (alternatively `192.168.1.[MACHINE]:443`).
Login in with
- user: `myuser`
- password: `44bb2d3f-d28f-4bcf-8f45-ae6ad2bc06b4`

1. Navigate to Scans > Tasks > Task Wizard and input the ip of the desired target.
2. Wait for like 30 mins :^)
3. Profit.
