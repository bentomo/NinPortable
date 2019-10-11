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
