# NinPortable
Source code for logic, board files, and 3D models needed to create a portable Nintendo console

Each folder contains readme's describing its purpose

## Setup
---------------------------------------
#### Download the required repositories
The required repositories will be cloned into the same directory as the NinPortable Repo

	cd build
	make setup

	Need to add verilator build
	Need to add wbuart32 download


#### Build the toolchain
The required rv32 tool chain needs to be downloaded and installed

	cd ../picorv32
	make download-tools
	make -j$(nproc) build-tools

	Yosys is currently required for a few tests, the build does not
	currently have a target FPGA. It will most likely be ECP5 but
	yosys does not yet support ECP5, it will ver soon.

	Testing is done with yosys https://github.com/YosysHQ/yosys at
	2daa56859f51631992cc172ccddad55e741b0c3d

## Test
---------------------------------------
You can run the main code test from the build directory
This calls a sub-make in the hw/tb/top directory

	cd build
	make np_top_sim

Or run with verilator

	cd build
	make np_top_sim_verilator

The test flow uses a mix of iverilog and verilator
Verilator is used when the sim needs to be sped up for firmware tests

Most designs will include a riscv softcore so the associated firmware for the
test will be located in the fw/tb directory

## Make options
---

The project is very large so we will attempt to manage it with make

### buildFPGA
---
This builds the bit stream and firmware to be loaded on to the FPGA

## Overview
---

#### Different Sub Disciplines of the design
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

#### Power
---
Controlled with Push Button  that disables regulator enables (minimize standby current draw)
	Standby power and main power
Main power is through either USB or Battery
	Battery charger management
	Battery Fuel Gauge
	Protection Circuitry for Cells

#### Video
---
LCD controller is integrated into FPGA
Data is converted directly to RGB for LCD
System settings are configurable through OSD
OSD is generated in DRAM using soft core processor

#### Audio
---
I2S is taken from FPGA and amplified
Outputs supported are speakers and headphone jack
Digital push button volume control

#### User Controller
---
Replica of Official control exists in RTL logic on FPGA
	External SPI ADC used for 4 analog directions (2 sticks)
Full button suite
	Does not include analog triggers
Used to control OSD

#### FPGA
---
FPGA is responsible for
	Standby Power Control (may change)
	Video/Audio processing and LCD control
	User controller logic
	Softcore processor
	User OSD
USB core to be added for bootloader and firmware updates

#### Enclosure Design
---
Need to design on 3d modeling tool
Options like Fusion360, freecad, openscad, are all being considered
3D printed beta design
Once finalized fit and play test is done. Second print is done and post processed to be used in plastic resin casting for finished enclosure
Brass knurls used for real screw posts


## Status
---
Power Subsystem needs redesigning to switch to TI instead of LT, also needs fuel gauge and OVL/UVL protection circuits
User Controller RTL is complete but needs ADC logic added
Soft core processor needs peripherals added for testing
	UART
	DRAM
Video Processor needs testbench and needs to be converted to verilog from VHDL
USB bootloader/update method needed


# License
---
This repository will uphold the open source nature of its sources

Copyright 2018 Austin Carter

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.