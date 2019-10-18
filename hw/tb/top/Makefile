#This is the Makefile descriptor for the main code
RISCV_GNU_TOOLCHAIN_GIT_REVISION = c3ad555
RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX = /opt/riscv32
GCC_WARNS  = -Werror -Wall -Wextra -Wshadow -Wundef -Wpointer-arith -Wcast-qual -Wcast-align -Wwrite-strings
GCC_WARNS += -Wredundant-decls -Wstrict-prototypes -Wmissing-prototypes -pedantic # -Wconversion
TOOLCHAIN_PREFIX = $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)i/bin/riscv32-unknown-elf-
COMPRESSED_ISA = C

GIT_PATH = ../../..
PICORV32_PATH = $(GIT_PATH)/../picorv32
PICORV32 = $(PICORV32_PATH)/picorv32.v
PICOSOC = $(PICORV32_PATH)/picosoc/picosoc.v
UART = $(PICORV32_PATH)/picosoc/simpleuart.v
NV_MEM = $(PICORV32_PATH)/picosoc/spiflash.v

TOP_WRAPPER = $(GIT_PATH)/hw/top/np_top.v

TESTBENCH = $(GIT_PATH)/hw/tb/np_top_tb.v
TESTBENCHVERI= $(GIT_PATH)/hw/tb/top/testbench.cc
MAINFW = $(GIT_PATH)/fw/main

top_sim_hello: np_demo_tb.vvp $(MAINFW)/np_fw.hex
	vvp -N $< +firmware=$(MAINFW)/np_fw.hex

np_demo_tb.vvp: $(TESTBENCH) $(TOP_WRAPPER) $(PICOSOC) $(PICORV32) $(UART) $(NV_MEM)
	iverilog -s testbench -o $@ $^ `yosys-config --datdir/ice40/cells_sim.v`

np_sections.lds: $(MAINFW)/sections.lds
	$(TOOLCHAIN_PREFIX)cpp -P -DSOCDEMO -o $@ $^

np_fw.hex: $(MAINFW)/np_fw.elf
	$(TOOLCHAIN_PREFIX)objcopy -O verilog $(MAINFW)/np_fw.elf $(MAINFW)/np_fw.hex

np_fw.bin: $(MAINFW)/np_fw.elf
	$(TOOLCHAIN_PREFIX)objcopy -O binary $(MAINFW)/np_fw.elf $(MAINFW)/np_fw.bin

np_fw.elf: $(MAINFW)/np_sections.lds $(MAINFW)/start.s $(MAINFW)/firmware.c
	$(TOOLCHAIN_PREFIX)gcc -DSOCDEMO -march=rv32imc -Wl,-Bstatic,-T,$(MAINFW)/np_sections.lds,--strip-debug -ffreestanding -nostdlib -o $(MAINFW)/np_fw.elf $(MAINFW)/start.s $(MAINFW)/firmware.c

clean:
	rm -f testbench.vvp testbench.vcd spiflash_tb.vvp spiflash_tb.vcd
	rm -f $(MAINFW)/np_fw.elf $(MAINFW)/np_fw.hex $(MAINFW)/np_fw.bin
	rm -f np_sections.lds
	rm -vrf $(MAINFW)/firmware.elf $(MAINFW)/firmware.bin $(MAINFW)firmware.hex $(MAINFW)firmware.map
	rm -vrf *.vvp *.vcd *.trace
	rm -vrf testbench_verilator testbench_verilator_dir

.PHONY: top_sim_hello clean