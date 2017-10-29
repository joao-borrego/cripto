## Assignment 4 - Firewalls

 * [1. Introduction](#1-introduction)
 * [2. `iptables`](#2--iptables-)
     + [2.1 Simple rules](#21-simple-rules)
    	- [2.1.1 Reject ICMP packets](#211-reject-icmp-packets)
    	- [2.1.2 Reject telnet connections](#211-212-reject-telnet-connections)
    	- [2.1.3 Reject telnet connections from a specific IP address](#213-reject-telnet-connections-from-a-specific-ip-address)
    	- [2.1.4 Reject telnet connections from a specific subnet](#214-reject-telnet-connections-from-a-specific-subnet)

### 1. Introduction

This assignment requires a slightly different network topology and an additional fourth machine.
The network is represented in the following diagram.

<img src=".images/assignment4_network.png?raw=true" width=700 />

In case you want to create the network from scratch, we created a [script for VirtualBox]
that configures each machine network interfaces accordingly.

### 2. `iptables`

Even though the native firewall software in Linux is part of the kernel it is possible to manage its rules
using `iptables`.

#### 2.1 Simple rules

Let's try some simple rules in machine 2.

##### 2.1.1 Reject ICMP packets

First verify that for instance machine 3 can query machine 2 with a simple ping request:
```
user@machine3:~$ ping machine2
PING machine2 (192.168.3.1) 56(84) bytes of data.
64 bytes from machine2 (192.168.3.1): icmp_seq=1 ttl=64 time=0.571 ms
```

Now run the following command in machine 2 to specify that icmp packets should be dropped:

`sudo iptables -A INPUT -p icmp -j DROP`

More specifically, this command appends a rule to the INPUT chain in the IPv4 packet filtering table,
stating that packets with the icmp protocol should be handled with a jump to the DROP action.
This will result in the matching packets being ignored in the configured machine.

Verify that the ping request from machine 3 will now fail.
You can check the list of existing rules in machine 2 by executing:

```
user@machine2:~$ sudo iptables -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination         
DROP       icmp --  anywhere             anywhere
```

Now remove the rule in machine 2 by using one of the two commands:
```
sudo iptables –D INPUT 1 # Deletes the first rule from the INPUT chain
sudo iptables –D INPUT –p icmp –j DROP # Deletes the ICMP rule specifically
```

##### 2.1.2 Reject telnet connections

First make sure you can establish a telnet connection with machine 2.
If not, refer to the [troubleshooting guide on telnet].

Now, in machine 2 add a rule to drop all packets with the destination port equal to 23 (telnet):
```
sudo iptables -A INPUT -p tcp --dport 23 -j DROP
```

Upon trying a telnet connection, the origin machine will now hang and fail.
Remove the rule in machine 2 with:
```
sudo iptables -D INPUT -p tcp --dport 23 -j DROP
```

##### 2.1.3 Reject telnet connections from a specific IP addresse

You can even specify you wish to ignore connections from a given IP address.
On machine 2 run:

```
sudo iptables -A INPUT -p tcp -s 192.168.1.1 --dport 23 -j DROP
```

Verify that only machine 1 will fail to establish a telnet connection.

##### 2.1.4 Reject telnet connections from a specific subnet

Furthermore, it is possible to block a specific subnet (which corresponds to a specific set of IP addresses)
The following command will block every machine in the subnet through which machine 4 can communicate with machine 2.

```
sudo iptables -A INPUT -p tcp -s 192.168.4.0/24 --dport 23 -j DROP
```

Verify that machine 4 will now be unable to establish a telnet connection.
In fact, it will be presented with a `Connection refused` error.

Delete all of the rules in machine 2 with:
```
sudo iptables -F # flush all the chains, deleting every rule
```

[script for VirtualBox]: vbox_assignment4.sh
[troubleshooting guide on telnet]: assignment1.md#establish-a-telnet-connection