## Assignment 2

### Setup

#### OpenVAS installation

OpenVAS is a framework of several services and tools offering a comprehensive and powerful vulnerability scanning and vulnerability management solution.
Essentially it will be used to check for vulnerabilities in the configuration of machines in our virtual network.

```
cd ~/csc-course/assignment2 &&
sudo ./startVas &&
chmod +x openvas-check-setup &&
sudo ./openvas-check-setup --v9 # The --v9 flag is needed for version checking
```

Should the check fail, follow the instructions in FIX

### 1. 

### 3. OpenVAS
Open the browser in `localhost` on the machine with openVAS (alternatively `192.168.1.[MACHINE]:443`).
Login in with
- user: `myuser`
- password: `44bb2d3f-d28f-4bcf-8f45-ae6ad2bc06b4`

1. Navigate to Scans > Tasks > Task Wizard and input the ip of the desired target.
2. Wait for like 30 mins :^)
3. Profit.