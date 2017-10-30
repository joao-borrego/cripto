# Make snapshot of machine 1
VBoxManage snapshot "machine1" take Machine1LinkedSnapshot

# Attack of the clones
VBoxManage clonevm "machine1" --snapshot Machine1LinkedSnapshot --mode machine --options link --name machine2 --register
VBoxManage clonevm "machine1" --snapshot Machine1LinkedSnapshot --mode machine --options link --name machine3 --register
VBoxManage clonevm "machine1" --snapshot Machine1LinkedSnapshot --mode machine --options link --name machine4 --register

# Machine 1 interfaces
VBoxManage modifyvm "machine1" --nic1 nat
VBoxManage modifyvm "machine1" --nictype1 82540EM
VBoxManage modifyvm "machine1" --macaddress1 420694206911

VBoxManage modifyvm "machine1" --nic2 intnet
VBoxManage modifyvm "machine1" --nictype2 82540EM
VBoxManage modifyvm "machine1" --nicpromisc2 allow-all
VBoxManage modifyvm "machine1" --intnet2 intnet1
VBoxManage modifyvm "machine1" --macaddress2 420694206912

# Machine 2 interfaces
VBoxManage modifyvm "machine2" --nic1 intnet
VBoxManage modifyvm "machine2" --nictype1 82540EM
VBoxManage modifyvm "machine2" --nicpromisc1 allow-all
VBoxManage modifyvm "machine2" --intnet1 intnet1
VBoxManage modifyvm "machine2" --macaddress1 420694206921

VBoxManage modifyvm "machine2" --nic2 intnet
VBoxManage modifyvm "machine2" --nictype2 82540EM
VBoxManage modifyvm "machine2" --nicpromisc2 allow-all
VBoxManage modifyvm "machine2" --intnet2 intnet3
VBoxManage modifyvm "machine2" --macaddress2 420694206922

VBoxManage modifyvm "machine2" --nic3 intnet
VBoxManage modifyvm "machine2" --nictype3 82540EM
VBoxManage modifyvm "machine2" --nicpromisc3 allow-all
VBoxManage modifyvm "machine2" --intnet3 intnet4
VBoxManage modifyvm "machine2" --macaddress3 420694206923

# Machine 3 interfaces
VBoxManage modifyvm "machine3" --nic1 intnet
VBoxManage modifyvm "machine3" --nictype1 82540EM
VBoxManage modifyvm "machine3" --nicpromisc1 allow-all
VBoxManage modifyvm "machine3" --intnet1 intnet3
VBoxManage modifyvm "machine3" --macaddress1 420694206931

# Machine 4 interfaces
VBoxManage modifyvm "machine4" --nic1 intnet
VBoxManage modifyvm "machine4" --nictype1 82540EM
VBoxManage modifyvm "machine4" --nicpromisc1 allow-all
VBoxManage modifyvm "machine4" --intnet1 intnet4
VBoxManage modifyvm "machine4" --macaddress1 420694206941




