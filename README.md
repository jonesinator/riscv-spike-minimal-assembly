# riscv-spike-minimal-assembly
This repository contains minimal RISC-V assembly language programs for
performing simple actions with Spike without the [Proxy Kernel][1].

## Programs

### empty.S

This program immediately causes Spike to exit with a good error status.

### console\_output.S

This program outputs "Hello, World!" by issuing a Spike "syscall" for
sys\_write.

## Files
* link.ld -- Simple linker script that sets the base address to `0x80000000`
  since the default address `0x10000` is in an invalid place for Spike. This
  address is the same that's used for the
  [RISC-V proxy kernel start address][1].
* \*.S -- The minimal assembly language examples.
* Makefile -- Builds executables and runs Spike on them. Contains the targets:
  * all -- Builds 32 and 64 bit ELF files for all assembly-language files in
           the directory.
  * elf32 -- Builds 32 bit ELF files for all assembly-language files in the
             directory.
  * elf64 -- Builds 64 bit ELF files for all assembly-language files in the
             directory.
  * run -- Uses spike to execute all 32 and 64 bit ELF files.
  * run32 -- Uses spike to execute all 32 bit ELF files.
  * run64 -- Uses spike to execute all 64 bit ELF files.
  * clean -- Removes any generated files.
  * clean32 -- Removes any 32 bit ELF files.
  * clean64 -- Removes any 64 bit ELF files.
  * clean -- Removes 32 and 64 bit ELF files.
  * \*\_32 -- Builds a particular 32 bit ELF file, i.e. `make empty_32`.
  * \*\_64 -- Builds a particular 64 bit ELF file, i.e. `make empty_64`.
  * \*\_32\_run -- Runs a particular 32 bit ELF file with Spike, i.e.
                   `make empty_32_run`.
  * \*\_64\_run -- Runs a particular 64 bit ELF file with Spike, i.e.
                   `make empty_64_run`.

[1]: https://github.com/riscv/riscv-pk/blob/fb4e31229fb072297dad9fcdf2c67b053c5d0322/pk/pk.lds#L13
