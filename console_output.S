# Simple assembly program that will print "Hello, World!" to the console
# through Spike.

.text
.global _start; _start:
  li sp, 0x80001000
  la a0, hello_world
  jal print_string
  li a0, 0
  j exit


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
