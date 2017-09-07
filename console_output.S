.section .text
.global _start; _start:
la t0, hello_world
la t1, syscall_string_ptr
sw t0, 0(t1)
la t2, syscall
la t3, tohost
sw t2, 0(t3)
1: lw t5, 0(t3)
bnez t5, 1b
li t4, 1
sw t4, 0(t3)
1: j 1b
.section .data
.align 6; .global tohost;   tohost:   .dword 0
.align 6; .global fromhost; fromhost: .dword 0
syscall:
.dword 64
.dword 1
syscall_string_ptr:
.dword 0
.dword 14
.dword 0
.dword 0
.dword 0
.dword 0
hello_world:
.string "Hello, World!\n"
