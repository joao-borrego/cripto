#!/bin/bash

# Make snapshot of Base machine
VBoxManage snapshot "Base" take BaseSnapshot

# Attack of the clones
VBoxManage clonevm "Base" --snapshot BaseSnapshot --mode machine --options link --name SP --register
VBoxManage clonevm "Base" --snapshot BaseSnapshot --mode machine --options link --name Browser --register
VBoxManage clonevm "Base" --snapshot BaseSnapshot --mode machine --options link --name IdP --register

# Clipboard sharing
VBoxManage modifyvm "SP" --clipboard bidirectional
VBoxManage modifyvm "Browser" --clipboard bidirectional
VBoxManage modifyvm "IdP" --clipboard bidirectional

# SP interfaces
VBoxManage modifyvm "SP" --nic1 nat
VBoxManage modifyvm "SP" --nictype1 82540EM
VBoxManage modifyvm "SP" --macaddress1 080043534311

VBoxManage modifyvm "SP" --nic2 intnet
VBoxManage modifyvm "SP" --nictype2 82540EM
VBoxManage modifyvm "SP" --nicpromisc2 allow-all
VBoxManage modifyvm "SP" --macaddress2 080043534312

# Browser interfaces
VBoxManage modifyvm "Browser" --nic1 nat
VBoxManage modifyvm "Browser" --nictype1 82540EM
VBoxManage modifyvm "Browser" --macaddress1 080043534321

VBoxManage modifyvm "Browser" --nic2 intnet
VBoxManage modifyvm "Browser" --nictype2 82540EM
VBoxManage modifyvm "Browser" --nicpromisc2 allow-all
VBoxManage modifyvm "Browser" --macaddress2 080043534322

# IdP interfaces
VBoxManage modifyvm "IdP" --nic1 nat
VBoxManage modifyvm "IdP" --nictype1 82540EM
VBoxManage modifyvm "IdP" --macaddress1 080043534331

VBoxManage modifyvm "IdP" --nic2 intnet
VBoxManage modifyvm "IdP" --nictype2 82540EM
VBoxManage modifyvm "IdP" --nicpromisc2 allow-all
VBoxManage modifyvm "IdP" --macaddress2 080043534332
