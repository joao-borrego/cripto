### Network Setup

Our internal network includes 3 separate machines:

- Service Provider (SP)
- Identity Provider (IdP)
- Service Client (Browser)

Our setup was implemented using VirtualBox virtual machines.
We created a Lubuntu 16.04.3 LTS virtual machine which will serve as our **Base**.
This machine will be cloned and its hard drive shared with the other virtual machines.
We used a 10 GB VMDK hard drive.
During the installation we chose the credentials username `user`, host `user` and password `inseguro`.

#### Virtual Machines Setup

We have written a script to automatically create our machine clones from the Base VM, using `VBoxManage` utility.
It assumes the base machine is named `Base`.
Each machine should have 2 network adapters

1. `NAT` for internet access,
2. `intnet1` for internal private network access.

The MAC addresses of the adapters each machine are used later for identifying the machines from within the OS, so they must be set to specific values, namely

| Machine | Adapter | Interface | MAC               |
|---------|---------|-----------|-------------------|
| SP      | 1       | NAT       | 08:00:43:53:43:11 |
| SP      | 2       | intnet1   | 08:00:43:53:43:12 |
| Browser | 1       | NAT       | 08:00:43:53:43:21 |
| Browser | 2       | intnet1   | 08:00:43:53:43:22 |
| IdP     | 1       | NAT       | 08:00:43:53:43:31 |
| IdP     | 2       | intnet1   | 08:00:43:53:43:32 |

By running [vbox.sh][vbox.sh] we should obtain the desired setup.

#### Network Connections Setup

Now we wish to configure the interface in each machine so they can have fixed IPs in the internal network.
This is required for our DNS to work.
We have also written a script for this step, which executed from within each of the virtual machines.
The following setup is achieved by running [network.sh][network.sh].

| Machine | Hostname | intnet1 IP     |
|---------|----------|----------------|
| SP      | sp       | 192.168.1.1/24 |
| Browser | browser  | 192.168.1.2/24 |
| IdP     | idp      | 192.168.1.3/24 |

In order for the hostname to change you have to **reboot** each machine.

Next: [DNS](https://github.com/jsbruglie/cripto/tree/dev/project#3-dns)

[vbox.sh]: vbox.sh
[network.sh]: network.sh
