#This is the Makefile descriptor for the main code
RISCV_GNU_TOOLCHAIN_GIT_REVISION = c3ad555
RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX = /opt/riscv32
GCC_WARNS  = -Werror -Wall -Wextra -Wshadow -Wundef -Wpointer-arith -Wcast-qual -Wcast-align -Wwrite-strings
GCC_WARNS += -Wredundant-decls -Wstrict-prototypes -Wmissing-prototypes -pedantic # -Wconversion
TOOLCHAIN_PREFIX = $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)i/bin/riscv32-unknown-elf-
COMPRESSED_ISA = C

#Verilator arguments
VERILATOR_ROOT ?= $(shell bash -c 'verilator -V|grep VERILATOR_ROOT | head -1 | sed -e " s/^.*=\s*//"')
CXX	:= g++
FLAGS	:= -Wall -Og -g
INCS	:= -Itb_verilator_dir -I$(VERILATOR_ROOT)/include

GIT_PATH = ../../..
PICORV32_PATH = $(GIT_PATH)/../picorv32
PICORV32 = $(PICORV32_PATH)/picorv32.v
PICOSOC = $(PICORV32_PATH)/picosoc/picosoc.v
UART = $(PICORV32_PATH)/picosoc/simpleuart.v
UARTSIM = $(GIT_PATH)/../wbuart32/bench/cpp/
NV_MEM = $(GIT_PATH)/hw/tb/spiflash/spiflash.v $(GIT_PATH)/hw/tb/spiflash/spimemio.v

TOP_WRAPPER = $(GIT_PATH)/hw/top/np_top.v

TESTBENCH = $(GIT_PATH)/hw/tb/top/np_top_tb.v
TESTBENCHVERI = $(GIT_PATH)/hw/tb/top/np_top_tb.cpp
MAINFW = $(GIT_PATH)/fw/main

#run sim using iverilog
np_top_sim: np_demo_tb.vvp np_fw.hex
	vvp -N $< +firmware=$(MAINFW)/np_fw.hex

#run sim using verilator
np_top_sim_verilator: np_top_tb_verilator np_fw.hex
	./np_top_tb_verilator +firmware=$(MAINFW)/np_fw.hex

#following rules support the two flows
np_top_tb_verilator: $(TESTBENCH) $(PICORV32) $(TOP_WRAPPER) $(PICOSOC) $(TESTBENCHVERI) $(UART) $(NV_MEM)
	verilator --cc --exe -Wno-lint -trace --top-module np_top_tb $(TESTBENCH) $(TOP_WRAPPER) $(PICOSOC) $(PICORV32) $(TESTBENCHVERI) $(UART) $(NV_MEM) \
			$(subst C,-DCOMPRESSED_ISA,$(COMPRESSED_ISA)) --Mdir tb_verilator_dir
	$(MAKE) -C tb_verilator_dir -f Vnp_top_tb.mk
	#might want to break this step out into a seperate verilator compile
	#$(CXX) $(FLAGS) $(INCS) $(TESTBENCHVERI) tb_verilator_dir/Vnp_top_tb__ALL.a -o $@
	cp tb_verilator_dir/Vnp_top_tb np_top_tb_verilator

np_demo_tb.vvp: $(TESTBENCH) $(TOP_WRAPPER) $(PICOSOC) $(PICORV32) $(UART) $(NV_MEM)
	iverilog -s np_top_tb -Wimplicit -Wportbind -Wno-timescale -o $@ $^

np_fw.hex: np_fw.bin
	$(TOOLCHAIN_PREFIX)objcopy -O verilog $(MAINFW)/np_fw.elf $(MAINFW)/np_fw.hex

np_fw.bin: np_fw.elf
	$(TOOLCHAIN_PREFIX)objcopy -O binary $(MAINFW)/np_fw.elf $(MAINFW)/np_fw.bin

np_fw.elf: np_sections.lds $(MAINFW)/start.s $(MAINFW)/firmware.c
	$(TOOLCHAIN_PREFIX)gcc -DSOCDEMO -march=rv32imc -Wl,-Bstatic,-T,$(MAINFW)/np_sections.lds,--strip-debug -ffreestanding -nostdlib -o $(MAINFW)/np_fw.elf $(MAINFW)/start.s $(MAINFW)/firmware.c

np_sections.lds: $(MAINFW)/sections.lds
	$(TOOLCHAIN_PREFIX)cpp -P -DSOCDEMO -o $(MAINFW)/$@ $^

clean:
	rm -f *.vvp *.vcd
	rm -f $(MAINFW)/np_fw.elf $(MAINFW)/np_fw.hex $(MAINFW)/np_fw.bin $(MAINFW)/np_sections.lds
	rm -vrf *.vvp *.vcd *.trace
	rm -vrf tb_verilator tb_verilator_dir np_top_tb_verilator

#Files are located in another directory so almost all rules are phony
.PHONY: np_top_sim np_top_sim_verilator np_tb_verilator np_demo_tb.vvp np_fw.hex np_fw.bin np_fw.elf np_sections.lds clean