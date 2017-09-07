.section .text
.global _start; _start:
li t0, 1
la t1, tohost
sw t0, 0(t1)
1: j 1b
.section .data
.align 6; .global tohost;   tohost:   .dword 0
.align 6; .global fromhost; fromhost: .dword 0
