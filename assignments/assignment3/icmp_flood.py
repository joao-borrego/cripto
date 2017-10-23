#! /usr/bin/env python
from scapy.all import *

def stopfilter(x):
	if x[TCP].flags == 16:
		return True
	else:
		return False

packets = sniff(filter='tcp', stop_filter=stopfilter)
packet = packets[-1]

src = packet[IP].src
dst = packet[IP].dst

while True:
	ans,unans = sr(IP(src=src, dst=dst)/ICMP())