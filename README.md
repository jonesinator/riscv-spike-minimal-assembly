# riscv-spike-minimal-assembly
This repository contains a minimal assembly program for terminating Spike with
a successful error code. This requires exposing `tohost` and `fromhost` symbols
(64-bit values, 64-bit aligned) in the ELF file so Spike and the assembly
program can communicate through shared memory. All the program actually does is
write `1` to `tohost` which Spike interprets as a command to terminate the
simulation with an exit code of `0`. After writing `1` to `tohost` the assembly
program just spins until Spike terminates the simulation. See the comments in
main.S for more detail.

## Files
* main.ld -- Simple linker script that sets the base address to `0x80000000`
  since the default address `0x10000` is in an invalid place for Spike. This
  address is the same that's used for the
  [RISC-V proxy kernel start address][1].
* main.S -- The RISC-V assembly file.
* Makefile -- Has three targets:
  * main --  Creates an ELF executable with GCC using main.S and main.ld.
  * run --   Creates the ELF executable if it is not up-to-date and runs it with
             Spike.
  * clean -- Removes any generated files.

[1]: https://github.com/riscv/riscv-pk/blob/fb4e31229fb072297dad9fcdf2c67b053c5d0322/pk/pk.lds#L13
