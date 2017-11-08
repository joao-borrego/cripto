## Assignment 5

- [Compiling](#compiling)
- [2. Buffer Overflows](#2-buffer-overflows)
  * [2.1 Change the return address](#21-change-the-return-address)
  * [2.2 Buffer overflow in stack](#22-buffer-overflow-in-stack)
  * [2.3 Buffer overflow in stack using perl](#23-buffer-overflow-in-stack-using-perl)
  * [2.4 Buffer overflow in stack using env variables](#24-buffer-overflow-in-stack-using-env-variables)
- [3. String Formats](#3-string-formats)


### Compiling

When compiling any program use the following command

`gcc -ggdb -fno-stack-protector -no-pie -m32 -z execstack [PROGRAM].c -o [PROGRAM]`

This will disable the dark magic behind the gcc.

### 2. Buffer Overflows

To understand what a buffer overflow read [this](http://insecure.org/stf/smashstack.html) and watch this [video](https://www.youtube.com/watch?v=1S0aBV-Waeo).

#### 2.1 Change the return address 

Assuming you have read the above, the stack for `overflow_function` should be something like

```
bottom 										top
of 											of
mem		|      [buffer] [SFP] [RET] [*str] |mem	
		|	   [   20B] [ 4B] [ 4B] [  4B] |

```

Compile the code and run `gdb overflow`. Using `disas overflow_function`, its observable that the compiler allocated 40 Bytes instead of 32 Bytes. (Why? No idea, something to do with the way it allocs memory)

```
0x0804843e <+3>:	sub    $0x28,%esp
```

Using a `big_string` of 32 Bytes, the program crashes, as it should since its trying to access memory passed 20 Bytes to write on it. Yet it does not write 'AAAAA' to the RET address. Using 36 Bytes, it will fully write the RET address, which is visible when you run the program in gdb. (Why? No idea)


#### 2.2 Buffer overflow in stack

Compile `vuln.c`, then change the ownership to root 

`sudo chown root vuln` 

and give it root privileges 

`chmod 4755 vuln` 

('4' activates SUID - Set owner User ID up on execution). 
What this last command does is give temporary permissions to a user to run a program/file with the permissions of the file owner (root) rather that the user who runs it. Furtherly, this will allow you to use a shell as root and fuck up the whole machine.

Compile and run `exploit.c`. Its really hard to discover where the return address is pointing to and modify that position content. So instead the objective is to overwrite the return address with the address of the buffer. And in buffer add the malicious code we want to execute! 

Looking at `exploit.c`: 

1) We try to find the address of where vuln.c buffer will be. This is done by finding out where out current stack pointer is and subtracting it an offset. Multiple attempts will be needed to get the offset right.

2) We allocate our malicious buffer *on the heap*! So it doesn't interfere with the rest. 600 Bytes are allocated to make sure it reaches the return address, since vuln.c buffer is 500 Bytes.

3) We fill the entire malicious buffer with the desired return address (aka the address that we think is where the vuln.c buffer will be).

4) We write around 200 Bytes of NOPs (each NOP is 1 Byte and its code is \x90) to the beggining of malicious buffer. The NOPs allow us to slide from byte to byte in the stack. It's needed because we arent entirely sure where the vuln.c buffer starts, so we don't want to put the malicious code right at the beggining, the NOPs will slide us to it.

5) We add the malicious code (about 46 Bytes) that consist on `execve()` to open a shell and `exit()` because in case execve() fails, we don't want the program fetching instructions from the stack, which may contain random data.

6) We finalize by putting '\0' at the end of the buffer so stcpy() stops writing.

So our malicious buffer and stack will be something like

```
buffer[600]: | NOPx200 | Shellcode | RETx~350          | '\0' |
stack:       | vuln.c Buffer[500]      | SPF | RET | *bf | ............ |
```

If everything works, it will open a shell as root.

#### 2.3 Buffer overflow in stack using perl

This does exactly the same as before in one line and using perl...
Notice that you need to get the return address and put it little Endian due to intel CPU.

` "\x3c\xed\xff\xbf"x88 ` 

88 Bytes of this should be enough to reach the return address.

#### 2.4 Buffer overflow in stack using env variables

TODO

### 3. String Formats

TODO


