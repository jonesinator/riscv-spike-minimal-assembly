main: main.S main.ld
	riscv32-unknown-elf-gcc -nostdlib -T main.ld main.S -o main

.PHONY: run
run: main
	spike main

.PHONY: clean
clean:
	rm -f main
