#!/bin/bash

# Copy DNS client configuration
sudo cp head_config /etc/resolvconf/resolv.conf.d/head
# Generate new resolv.conf file
sudo resolvconf -u