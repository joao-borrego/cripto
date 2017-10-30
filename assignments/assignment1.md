## Assignment 1

**TODO**

### Troubleshooting

#### Establish a telnet connection

On the destination machine you might have to fix a configuration error in telnet.
Create a file called `telnet` with the following contents.

```
# default: on
# description: The telnet server serves telnet sessions; it uses
# unencrypted username/password pairs for authentication.
service telnet
{
disable = no
flags = REUSE
socket_type = stream
wait = no
user = root
server = /usr/sbin/in.telnetd
log_on_failure += USERID
}
```

Run the following commands to copy the configurations and restart the service:
```
sudo apt install xinetd telnetd
sudo cp telnet  /etc/xinetd.d/telnet
sudo /etc/init.d/xinetd restart
```