.section .text
.global _start; _start:

# Write the value 1 into the tohost memory. This sends a command to Spike that
# will terminate the simulation with a good status.
#
# The commands we send to Spike by writing to tohost are 64-bits and consist of
# a device, command, and payload. The device is the most significant 8 bits of
# tohost. In this case, the device is 0, which is a syscall_t device because
# the syscall_t device is added to the htif's device_list first, so it is at
# index 0. The command is the next most significant 8-bits. In this case the
# command is also 0, which is registered to the function
# syscall_t::handle_syscall (it is the only command that sycall_t registers).
# The payload is the least significant 48 bits. In this case the command is 1.
# If the least significant bit in the payload is 1 then it is interpreted as a
# request to terminate the program, otherwise the command is interpreted as a
# syscall, and syscall_t::dispatch is called to handle it. In this case the
# least significant bit is indeed 1, so the simulation will be terminated. The
# remaining 47 bits of the payload are interpreted as the exit code of Spike.
# In this case the exit code will be 0, meaning a successful exit. If we
# replace 1 with 3 in the line below then the exit code will be 1 and the
# program will terminate with an error status.
li gp, 1
la t5, tohost
sw gp, 0(t5)

# Jump to the same line we're on, effectively looping forever until Spike kills
# the program.
1: j 1b

# Create the .data section containing both the "tohost" and "fromhost" memory
# areas that are used to communicate with Spike. They are both 64-bit values
# (dwords) aligned on 64-bit boundaries (2^6 bits). The size and alignment are
# required by Spike.
.section .data
.align 6; .global tohost;   tohost:   .dword 0
.align 6; .global fromhost; fromhost: .dword 0
