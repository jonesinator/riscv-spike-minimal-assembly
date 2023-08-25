# Simple assembly program that will print "Hello, World!" to the console
# through Spike.

.text
.global _start; _start:
  li sp, 0x80001000
  la a0, hello_world
  jal print_string

  # Code to print Hexadecimal Register values
  la a0, stack_value
  jal print_string
  move a0,sp
  jal hex_2_string
  la a0, hexpad
  jal print_string

  li a0, 0
  j exit

# A function(hex_2_string) to convert register value into ascii string and store it in the scratchpad
#
# Registers Used:
#   ra, a0, t0-t4
#
# Parameters:
#   a0 - Hex number
#
# Code Logic: 
#	1. Take one 4 bit nibble at a time from 32/64 bit register using masking.
#	2. adding appropriate ascii value to convert into an ascii format.
#	3. calculate appropriate scratchpad address and store the ascii.
#
# Returns:
#   scratchpad: 8byte Memory sapce define in the end of file
#
hex_2_string:
  	# save retrun to stack
	addi sp, sp, -8
	sw ra, (sp)
	
	# Here t4 is counter value for scratchpad addressing used in label 2 
	# for 32bit 0x07 and size of scratchpad is 8 byte 
	# for 64bit 0x0F and size of scratchpad is 16 byte
	move t0,a0
	li t4, 0x07	
1:
	andi t1,t0,0x0F
	li t2,9
	bgt t1,t2, A2F
 # byte contains 0-9 numbers
 # 0x30 + 1 ===> 0x31 which is ascii for Number '1'
numbers:
	li t2,0x30
	add t2,t2,t1
	j 2f
 # byte contains to A-F hexadecimal numbers
 # 0x37 + A ===> 0x41 which is ascii for letter 'A'
A2F:
	li t2,0x37
	add t2,t2,t1
2:	
	la t3, scratchpad
	add t3,t3,t4
	sb t2,0(t3)
	addi t4,t4,-1
	srli t0,t0,4
	bnez t0,1b
  # Pop the return address of the stack and return control to the caller.
hex_2_string_end:
	lw ra, (sp)
	addi sp, sp, 8
	ret


# Makes a Spike syscall. See riscv-fesvr/fesvr/syscall.cc.
#
# Registers Used:
#   ra, a0-a7, t0-t2
#
# Parameters:
#   a0 - Syscall number.
#   a1-a7 - Syscall arguments.
#
# Returns:
#   a0 - Return value of syscall.
#
# Notes:
#   Leaf function.
syscall:
  # Store the arguments in the syscall_buffer.
  la t0, syscall_buffer
  sw a0, (t0)
  sw a1, 8(t0)
  sw a2, 16(t0)
  sw a3, 24(t0)
  sw a4, 32(t0)
  sw a5, 40(t0)
  sw a6, 48(t0)
  sw a7, 56(t0)

  # Write the address of the syscall_buffer to tohost, this tells Spike to
  # actually perform the syscall.
  la t1, tohost
  sw t0, (t1)

  # tohost will now be set to zero by Spike, indicating that the syscall request
  # has been seen. We could wait for it here, but the next step is to wait for
  # fromhost to become non-zero, which can't happen before tohost is set to
  # zero anyway, so we don't waste code waiting for it.

  # Wait for fromhost to get a nonzero value. Once it becomes nonzero we know
  # Spike has completed the syscall. Set it back to 0 once Spike is done.
  la t1, fromhost
  1: lw t2, (t1)
  beqz t2, 1b
  sw zero, (t1)

  # Put the first word of the syscall_buffer into a0, that is the return code.
  lw a0, (t0)
  ret


# Terminates the program with a given status by making a sys_exit Spike syscall.
#
# Registers Used:
#   a0, a1
#
# Parameters:
#   a0 - Exit status.
#
# Notes:
#   Can never return.
exit:
  move a1, a0
  li a0, 93
  jal syscall
  1: j 1b


# Prints a string to the console.
#
# Registers Used:
#   ra, a0, a1, t6
#
# Parameters:
#   a0 - Contains the address of the string to print.
#
# Returns:
#   a0 - The return code of the sys_write syscall used to print the string.
print_string:
  # Save the return address to the stack so we can call subroutines.
  addi sp, sp, -8
  sw ra, (sp)

  # Get the string address into a2, which is where syscall expects it.
  move a2, a0

  # Get the string length into a3, which is where syscall expects it.
  jal string_length
  move a3, a0

  # Make a syscall to write the string to stdout.
  li a0, 64 # sys_write
  li a1, 1  # file descriptor (stdout)
  jal syscall

  # Pop the return address of the stack and return control to the caller.
  lw ra, (sp)
  addi sp, sp, 8
  ret


# Determines the length of a null-terminated string.
#
# Registers Used:
#   ra, a0, t0, t1
#
# Parameters:
#   a0 -- The address of the string whose length should be calculated.
#
# Returns:
#   a0 -- The length of the string.
#
# Notes:
#   Leaf function.
string_length:
  move t0, a0
  1: lb t1, (t0)
     beqz t1, 1f
     addi t0, t0, 1
     j 1b
  1: sub a0, t0, a0
     ret


.data
.align 6; .global tohost;   tohost:   .dword 0
.align 6; .global fromhost; fromhost: .dword 0
syscall_buffer:
.skip 64
hello_world:
.string "Hello, World!\n"

stack_value:
.string "Value of Stack Register = "

hexpad:
.ascii "0x"
scratchpad:
.skip 8
.string "\n"
