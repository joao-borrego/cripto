#!/bin/bash

# Compile code
# -ggdb produces debugging information specific to gdb
# -fno-stack-protector disables stack protector check
# -m32 ensures 32 bit (4 Byte) alignment on stack data
# -z execstack passes the execstack argument to the linker
#	thus allowing the data on the stack to be executed as code
gcc -ggdb -fno-stack-protector -m32 -z execstack $1.c -o $1

# Change program ownership to root
sudo chown root $1

# Change program privileges in order to run with root privileges
#	(b100 = 4 activates the SUID flag)
sudo chmod 4755 $1