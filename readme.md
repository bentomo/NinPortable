# NinPortable
Source code for logic, board files, and 3D models needed to create a portable Nintendo console

Each folder contains readme's describing its purpose

##Setup
---------------------------------------
####Download the required repositories
The required repositories will be cloned into the same directory as the NinPortable Repo

	cd build
	make download


####Build the toolchain
The required rv32 tool chain needs to be downloaded and installed

	cd ../picorv32
	make download-tools
	make -j$(nproc) build-tools


##Test
---------------------------------------
You can run a simple test with iverilog and verilator

	make test

	make test_verilator

##Make options
---

The project is very large so we will attempt to manage it with make

###Verification options
---
When features and functions are added they are given a rule in make to verify function in some way. When they are added there is a master verfication rule that will verify all sub-verification steps.
You can run the following make rules from the top level directory of git

####verify
---
This rule verifies all following verification rules

####verifyUART
---
This rule instances two picorv32 that will send messages to eachother over a serial wire


##Overview
---

####Different Sub Disciplines of the design
---
Power, sequencing, and Battery Management
Video Display and Buffering
On Screed User display
Audio Speaker and headphone control
FPGA core
	USB firmware updates
	Processor for OSD
User Controller
Enclosure Design

####Power
---
Controlled with Push Button  that disables regulator enables (minimize standby current draw)
	Standby power and main power
Main power is through either USB or Battery
	Battery charger management
	Battery Fuel Gauge
	Protection Circuitry for Cells

####Video
---
LCD controller is integrated into FPGA
Data is converted directly to RGB for LCD
System settings are configurable through OSD
OSD is generated in DRAM using soft core processor

####Audio
---
I2S is taken from FPGA and amplified
Outputs supported are speakers and headphone jack
Digital push button volume control

####User Controller
---
Replica of Official control exists in RTL logic on FPGA
	External SPI ADC used for 4 analog directions (2 sticks)
Full button suite
	Does not include analog triggers
Used to control OSD

####FPGA
---
FPGA is responsible for
	Standby Power Control (may change)
	Video/Audio processing and LCD control
	User controller logic
	Softcore processor
	User OSD
USB core to be added for bootloader and firmware updates

####Enclosure Design
---
Need to design on 3d modeling tool
Options like Fusion360, freecad, openscad, are all being considered
3D printed beta design
Once finalized fit and play test is done. Second print is done and post processed to be used in plastic resin casting for finished enclosure
Brass knurls used for real screw posts


##Status
---
Power Subsystem needs redesigning to switch to TI instead of LT, also needs fuel gauge and OVL/UVL protection circuits
User Controller RTL is complete but needs ADC logic added
Soft core processor needs peripherals added for testing
	UART
	DRAM
Video Processor needs testbench and needs to be converted to verilog from VHDL
USB bootloader/update method needed