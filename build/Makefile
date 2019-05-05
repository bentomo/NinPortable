#Initial makefile - nothing to see here

RISCV_GNU_TOOLCHAIN_GIT_REVISION = c3ad555
RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX = /opt/riscv32
FIRMWARE_OBJS = fw/start.o fw/irq.o fw/print.o fw/main.o
GCC_WARNS  = -Werror -Wall -Wextra -Wshadow -Wundef -Wpointer-arith -Wcast-qual -Wcast-align -Wwrite-strings
GCC_WARNS += -Wredundant-decls -Wstrict-prototypes -Wmissing-prototypes -pedantic # -Wconversion
TOOLCHAIN_PREFIX = $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)i/bin/riscv32-unknown-elf-
COMPRESSED_ISA = C
PICORV32_PATH = ../../picorv32


fw/firmware.hex: fw/firmware.bin $(PICORV32_PATH)/firmware/makehex.py
	python3 $(PICORV32_PATH)/firmware/makehex.py $< 16384 > $@

fw/firmware.bin: fw/firmware.elf
	$(TOOLCHAIN_PREFIX)objcopy -O binary $< $@
	chmod -x $@

fw/firmware.elf: $(FIRMWARE_OBJS) fw/sections.lds
	$(TOOLCHAIN_PREFIX)gcc -Os -ffreestanding -nostdlib -o $@ \
		-Wl,-Bstatic,-T,firmware/sections.lds,-Map,firmware/firmware.map,--strip-debug \
		$(FIRMWARE_OBJS) -lgcc
	chmod -x $@

fw/start.o: fw/start.S
	$(TOOLCHAIN_PREFIX)gcc -c -march=rv32im$(subst C,c,$(COMPRESSED_ISA)) -o $@ $<

fw/%.o: fw/%.c
	$(TOOLCHAIN_PREFIX)gcc -c -march=rv32i$(subst C,c,$(COMPRESSED_ISA)) -Os --std=c99 $(GCC_WARNS) -ffreestanding -nostdlib -o $@ $<

#This build is working with picorv32 revision from May 04, 2019
download:
	sudo bash -c 'cd ../..; git clone https://github.com/cliffordwolf/picorv32.git; \
		cd picorv32; git checkout b7e82dfcd1346c3b3fd7ac3ebd647907fc9ce06c;'

clean:
	#sudo bash -c 'rm -r $(PICORV32_PATH)'

.PHONY: download clean