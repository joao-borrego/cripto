#!/bin/bash

# Make snapshot of Base machine
VBoxManage snapshot "Base" take BaseSnapshot

# Attack of the clones
VBoxManage clonevm "Base" --snapshot BaseSnapshot --mode machine --options link --name SP --register
VBoxManage clonevm "Base" --snapshot BaseSnapshot --mode machine --options link --name Browser --register
VBoxManage clonevm "Base" --snapshot BaseSnapshot --mode machine --options link --name IdP1 --register
VBoxManage clonevm "Base" --snapshot BaseSnapshot --mode machine --options link --name WAYF --register
VBoxManage clonevm "Base" --snapshot BaseSnapshot --mode machine --options link --name IdP2 --register

# Clipboard sharing
VBoxManage modifyvm "SP" --clipboard bidirectional
VBoxManage modifyvm "Browser" --clipboard bidirectional
VBoxManage modifyvm "IdP1" --clipboard bidirectional
VBoxManage modifyvm "WAYF" --clipboard bidirectional
VBoxManage modifyvm "IdP2" --clipboard bidirectional

# SP interfaces
VBoxManage modifyvm "SP" --nic1 nat
VBoxManage modifyvm "SP" --nictype1 82540EM
VBoxManage modifyvm "SP" --macaddress1 080043534311

VBoxManage modifyvm "SP" --nic2 intnet
VBoxManage modifyvm "SP" --nictype2 82540EM
VBoxManage modifyvm "SP" --nicpromisc2 allow-all
VBoxManage modifyvm "SP" --macaddress2 080043534312

# Browser interfaces
VBoxManage modifyvm "Browser" --nic1 intnet
VBoxManage modifyvm "Browser" --nictype1 82540EM
VBoxManage modifyvm "Browser" --nicpromisc1 allow-all
VBoxManage modifyvm "Browser" --macaddress1 080043534321

# IdP1 interfaces
VBoxManage modifyvm "IdP1" --nic1 intnet
VBoxManage modifyvm "IdP1" --nictype1 82540EM
VBoxManage modifyvm "IdP1" --nicpromisc1 allow-all
VBoxManage modifyvm "IdP1" --macaddress1 080043534331

# WAYF interfaces
VBoxManage modifyvm "WAYF" --nic1 intnet
VBoxManage modifyvm "WAYF" --nictype1 82540EM
VBoxManage modifyvm "WAYF" --nicpromisc1 allow-all
VBoxManage modifyvm "WAYF" --macaddress1 080043534341

# IdP2 interfaces
VBoxManage modifyvm "IdP2" --nic1 intnet
VBoxManage modifyvm "IdP2" --nictype1 82540EM
VBoxManage modifyvm "IdP2" --nicpromisc1 allow-all
VBoxManage modifyvm "IdP2" --macaddress1 080043534351


