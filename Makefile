TARGETS = $(patsubst %.S,%,$(wildcard *.S))
define make-target
all:: elf32 elf64
elf32:: $(1)_32
elf64:: $(1)_64
run:: $(1)_32_run $(1)_64_run
run32:: $(1)_32_run
run64:: $(1)_64_run
$(1)_32: $(1).S link.ld
	riscv32-unknown-elf-gcc -nostdlib -T link.ld $(1).S -o $(1)_32
$(1)_64: $(1).S link.ld
	riscv64-unknown-elf-gcc -nostdlib -T link.ld $(1).S -o $(1)_64
.PHONY: $(1)_32_run
$(1)_32_run: $(1)_32
	spike --isa=rv32gc $(1)_32
.PHONY: $(1)_64_run
$(1)_64_run: $(1)_64
	spike --isa=rv64gc $(1)_64
endef
$(foreach element, $(TARGETS), $(eval $(call make-target, $(element))))
clean_32:
	rm -f $(patsubst %.S,%_32,$(wildcard *.S))
clean_64:
	rm -f $(patsubst %.S,%_64,$(wildcard *.S))
clean: clean_32 clean_64
