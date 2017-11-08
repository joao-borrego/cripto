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

#### 2.3 Buffer overflow in stack using perl

#### 2.4 Buffer overflow in stack using env variables

### 3. String Formats

