#Make file for project management

PICORV32_PATH = ../picorv32
RISCV_GNU_TOOLCHAIN_GIT_REVISION = c3ad555
RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX = /opt/riscv32
FIRMWARE_OBJS = fw/start.o fw/irq.o fw/print.o fw/main.o
PICORV32 = $(PICORV32_PATH)/picorv32.v
TESTBENCH = hw/tb/testbench.v
TESTBENCHVERI= hw/tb/testbench.cc
GCC_WARNS  = -Werror -Wall -Wextra -Wshadow -Wundef -Wpointer-arith -Wcast-qual -Wcast-align -Wwrite-strings
GCC_WARNS += -Wredundant-decls -Wstrict-prototypes -Wmissing-prototypes -pedantic # -Wconversion
TOOLCHAIN_PREFIX = $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)i/bin/riscv32-unknown-elf-
COMPRESSED_ISA = C


test: testbench.vvp fw/firmware.hex
	vvp -N $<

test_vcd: testbench.vvp fw/firmware.hex
	vvp -N $< +vcd +trace +noerror

test_verilator: testbench_verilator fw/firmware.hex
	./testbench_verilator

testbench_verilator: $(TESTBENCH) $(PICORV32) $(TESTBENCHVERI)
	verilator --cc --exe -Wno-lint -trace --top-module picorv32_wrapper $(TESTBENCH) $(PICORV32) $(TESTBENCHVERI) \
			$(subst C,-DCOMPRESSED_ISA,$(COMPRESSED_ISA)) --Mdir testbench_verilator_dir
	$(MAKE) -C testbench_verilator_dir -f Vpicorv32_wrapper.mk
	cp testbench_verilator_dir/Vpicorv32_wrapper testbench_verilator

testbench.vvp: $(TESTBENCH) $(PICORV32)
	iverilog -o $@ $(subst C,-DCOMPRESSED_ISA,$(COMPRESSED_ISA)) $^
	chmod -x $@

fw/firmware.hex: fw/firmware.bin $(PICORV32_PATH)/firmware/makehex.py
	python3 $(PICORV32_PATH)/firmware/makehex.py $< 16384 > $@

fw/firmware.bin: fw/firmware.elf
	$(TOOLCHAIN_PREFIX)objcopy -O binary $< $@
	chmod -x $@

fw/firmware.elf: $(FIRMWARE_OBJS) fw/sections.lds
	$(TOOLCHAIN_PREFIX)gcc -Os -ffreestanding -nostdlib -o $@ \
		-Wl,-Bstatic,-T,fw/sections.lds,-Map,fw/firmware.map,--strip-debug \
		$(FIRMWARE_OBJS) -lgcc
	chmod -x $@

fw/start.o: fw/start.S
	$(TOOLCHAIN_PREFIX)gcc -c -march=rv32im$(subst C,c,$(COMPRESSED_ISA)) -o $@ $<

fw/%.o: fw/%.c
	$(TOOLCHAIN_PREFIX)gcc -c -march=rv32i$(subst C,c,$(COMPRESSED_ISA)) -Os --std=c99 $(GCC_WARNS) -ffreestanding -nostdlib -o $@ $<

#This build is working with picorv32 revision from May 04, 2019
download:
	sudo bash -c 'cd ..; git clone https://github.com/cliffordwolf/picorv32.git; \
		cd picorv32; git checkout b7e82dfcd1346c3b3fd7ac3ebd647907fc9ce06c;'


###############################################################################
# Verification sections
###############################################################################

verify: verifyUART

verifyUART:

###############################################################################



clean:
	rm -vrf $(FIRMWARE_OBJS)
	rm -vrf fw/firmware.elf fw/firmware.bin fw/firmware.hex fw/firmware.map
	rm -vrf *.vvp *.vcd *.trace
	rm -vrf testbench_verilator testbench_verilator_dir
	#sudo bash -c 'rm -r $(PICORV32_PATH)'

.PHONY: download clean