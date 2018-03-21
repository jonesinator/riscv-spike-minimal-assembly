define make-target
elf:: bin/$(1)
run:: $(1)_run
bin/$(1): $(1).S link.ld
	riscv32-hifive1-elf-gcc -nostdlib -T link.ld $(1).S -o bin/$(1)
.PHONY: $(1)_run
$(1)_run: bin/$(1)
	spike -m1 --isa=RV32IMAC bin/$(1)
endef
TARGETS = $(patsubst %.S,%,$(wildcard *.S))
$(foreach element,$(TARGETS),$(eval $(call make-target,$(element))))
clean:
	cd bin && rm -f $(TARGETS)
