#Make file for project management


TOP_WRAPPER = ../hw/top/top_np.v
TB_PATH = ../hw/tb


PICORV32_PATH = ../../picorv32
RISCV_GNU_TOOLCHAIN_GIT_REVISION = c3ad555
RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX = /opt/riscv32
FIRMWARE_OBJS = ../fw/start.o ../fw/irq.o ../fw/print.o ../fw/main.o
PICORV32 = $(PICORV32_PATH)/picorv32.v
PICOSOC = $(PICORV32_PATH)/picosoc/picosoc.v
SOC_TBFW = ../fw/tb/soc
UTILITY_PERIPH = $(PICORV32_PATH)/picosoc/simpleuart.v $(PICORV32_PATH)/picosoc/spimemio.v $(PICORV32_PATH)/picosoc/spiflash.v

TESTBENCH = ../hw/tb/testbench.v
TESTBENCHVERI= ../hw/tb/testbench.cc
GCC_WARNS  = -Werror -Wall -Wextra -Wshadow -Wundef -Wpointer-arith -Wcast-qual -Wcast-align -Wwrite-strings
GCC_WARNS += -Wredundant-decls -Wstrict-prototypes -Wmissing-prototypes -pedantic # -Wconversion
TOOLCHAIN_PREFIX = $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)i/bin/riscv32-unknown-elf-
COMPRESSED_ISA = C

###############################################################################
# Picorv32 test section
###############################################################################
test: testbench.vvp ../fw/firmware.hex
	vvp -N $<

test_vcd: testbench.vvp ../fw/firmware.hex
	vvp -N $< +vcd +trace +noerror

test_verilator: testbench_verilator ../fw/firmware.hex
	./testbench_verilator

testbench_verilator: $(TESTBENCH) $(PICORV32) $(TESTBENCHVERI)
	verilator --cc --exe -Wno-lint -trace --top-module picorv32_wrapper $(TESTBENCH) $(PICORV32) $(TESTBENCHVERI) \
			$(subst C,-DCOMPRESSED_ISA,$(COMPRESSED_ISA)) --Mdir testbench_verilator_dir
	$(MAKE) -C testbench_verilator_dir -f Vpicorv32_wrapper.mk
	cp testbench_verilator_dir/Vpicorv32_wrapper testbench_verilator

testbench.vvp: $(TESTBENCH) $(PICORV32)
	iverilog -o $@ $(subst C,-DCOMPRESSED_ISA,$(COMPRESSED_ISA)) $^
	chmod -x $@

../fw/firmware.hex: ../fw/firmware.bin $(PICORV32_PATH)/firmware/makehex.py
	python3 $(PICORV32_PATH)/firmware/makehex.py $< 16384 > $@

../fw/firmware.bin: ../fw/firmware.elf
	$(TOOLCHAIN_PREFIX)objcopy -O binary $< $@
	chmod -x $@

../fw/firmware.elf: $(FIRMWARE_OBJS) ../fw/sections.lds
	$(TOOLCHAIN_PREFIX)gcc -Os -ffreestanding -nostdlib -o $@ \
		-Wl,-Bstatic,-T,../fw/sections.lds,-Map,../fw/firmware.map,--strip-debug \
		$(FIRMWARE_OBJS) -lgcc
	chmod -x $@

../fw/start.o: ../fw/start.S
	$(TOOLCHAIN_PREFIX)gcc -c -march=rv32im$(subst C,c,$(COMPRESSED_ISA)) -o $@ $<

../fw/%.o: ../fw/%.c
	$(TOOLCHAIN_PREFIX)gcc -c -march=rv32i$(subst C,c,$(COMPRESSED_ISA)) -Os --std=c99 $(GCC_WARNS) -ffreestanding -nostdlib -o $@ $<

#This build is working with picorv32 revision from May 04, 2019
setup:
	sudo bash -c 'cd ../..; git clone https://github.com/cliffordwolf/picorv32.git; \
		cd picorv32; git checkout b7e82dfcd1346c3b3fd7ac3ebd647907fc9ce06c;'

###############################################################################

###############################################################################
# Verification section
###############################################################################

verify: verifyUART
	./verifyUART

#recipe rtl contains files used in sim and design, add more rtl here
UART_RTL_RECIPE = $(TOP_WRAPPER) $(PICORV32)
UART_TESTBENCHVERI = ../hw/tb/uart/uart_testbench.cpp
UART_TESTBENCH = ../hw/tb/uart/uart_testbench.v
verifyUART: $(UART_RTL_RECIPE) $(UART_TESTBENCHVERI) $(UART_TESTBENCH)
	verilator --cc --exe -Wno-lint -trace --top-module top_np $(UART_RTL_RECIPE) $(PICORV32) $(UART_TESTBENCH) \
			$(subst C,-DCOMPRESSED_ISA,$(COMPRESSED_ISA)) --Mdir testbench_verilator_dir
	$(MAKE) -C testbench_verilator_dir -f Vtop_np.mk
	cp testbench_verilator_dir/Vtop_np testbench_verilator

###############################################################################

###############################################################################
# Picosoc test section
###############################################################################

#-----------may want to move this section into sub Make file in soc tb -----
picosoc_sim: picosoc_demo_tb.vvp $(SOC_TBFW)/socdemo_fw.hex
	vvp -N $< +firmware=$(SOC_TBFW)/socdemo_fw.hex

picosoc_demo_tb.vvp: $(TB_PATH)/soc/picosoc_demo_tb.v $(TB_PATH)/soc/picosoc_demo.v $(PICOSOC) $(PICORV32) $(UTILITY_PERIPH)
	iverilog -s testbench -o $@ $^ `yosys-config --datdir/ice40/cells_sim.v`

picosoc_sections.lds: $(SOC_TBFW)/sections.lds
	$(TOOLCHAIN_PREFIX)cpp -P -DSOCDEMO -o $@ $^

socdemo_fw.hex: $(SOC_TBFW)/socdemo_fw.elf
	$(TOOLCHAIN_PREFIX)objcopy -O verilog $(SOC_TBFW)/socdemo_fw.elf $(SOC_TBFW)/socdemo_fw.hex

socdemo_fw.bin: $(SOC_TBFW)/socdemo_fw.elf
	$(TOOLCHAIN_PREFIX)objcopy -O binary $(SOC_TBFW)/socdemo_fw.elf $(SOC_TBFW)/socdemo_fw.bin

socdemo_fw.elf: $(SOC_TBFW)/socdemo_sections.lds $(SOC_TBFW)/start.s $(SOC_TBFW)/firmware.c
	$(TOOLCHAIN_PREFIX)gcc -DSOCDEMO -march=rv32imc -Wl,-Bstatic,-T,$(SOC_TBFW)/socdemo_sections.lds,--strip-debug -ffreestanding -nostdlib -o $(SOC_TBFW)/socdemo_fw.elf $(SOC_TBFW)/start.s $(SOC_TBFW)/firmware.c

# ---- Testbench for SPI Flash Model ----

spiflash_tb: spiflash_tb.vvp firmware.hex
	vvp -N $<

spiflash_tb.vvp: spiflash.v spiflash_tb.v
	iverilog -s testbench -o $@ $^

###############################################################################

###############################################################################
# build section - output usable binarys and fab files
###############################################################################

BUILD_FPGA_RTL_RECIPE = $(TOP_WRAPPER)
buildFPGAbitstream: $(BUILD_FPGA_RTL_RECIPE)

###############################################################################

clean:
	rm -vrf $(FIRMWARE_OBJS)
	rm -f testbench.vvp testbench.vcd spiflash_tb.vvp spiflash_tb.vcd
	rm -f $(SOC_TBFW)/socdemo_fw.elf $(SOC_TBFW)/socdemo_fw.hex $(SOC_TBFW)/socdemo_fw.bin
	rm -f picosoc_sections.lds
	rm -vrf ../fw/firmware.elf ../fw/firmware.bin ../fw/firmware.hex ../fw/firmware.map
	rm -vrf *.vvp *.vcd *.trace
	rm -vrf testbench_verilator testbench_verilator_dir
	#sudo bash -c 'rm -r $(PICORV32_PATH)'

.PHONY: download clean
.PHONY: picosoc_sim
