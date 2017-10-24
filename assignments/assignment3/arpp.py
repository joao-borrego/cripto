#! /usr/bin/env python
from scapy.all import *

import sys, getopt

def main(argv):
	dstMAC = 'ff:ff:ff:ff:ff:ff'
	srcMAC = 'ff:ff:ff:ff:ff:ff'
	srcIP = '127.0.0.1'
	dstIP = '127.0.0.1'
	devID = 'enp0s3'

	try:
		# Parses the argument list from the command line
		# opts gets the flag
		# args gets the argument
		opts, args = getopt.getopt(argv,"HS:D:h:m:i:")
	except getopt.GetoptError:
		print 'arpp.py -S <srcIP> -D <dstIP> -h <srcMAC> -m <dstMAC>  -i <ifName>'
		sys.exit(2)
	for opt, arg in opts:
		if opt in ("-H"):
			print 'arpp.py -S <srcIP> -D <dstIP> -h <srcMAC> -m <dstMAC>  -i <ifName>'
			sys.exit(0)
		if opt in ("-S"):
			srcIP = arg
		elif opt in ("-D"):
			dstIP = arg
		elif opt in ("-h"):
			srcMAC = arg
		elif opt in ("-m"):
			dstMAC = arg
		elif opt in ("-i"):
			devID = arg


	sendp(Ether(dst=dstMAC, src=srcMAC)/ARP(hwsrc=srcMAC, hwdst=dstMAC, psrc=srcIP, pdst=dstIP), iface=devID)


if __name__ == "__main__":
	main(sys.argv[1:])
