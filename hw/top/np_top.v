/*

top level wrapper for FPGA design

This file was originally copied from the picosoc_demo.v file

Copywright 2019 Austin Carter <austinbennettcarter@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in 
the Software without restriction, including without limitation the rights to 
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
of the Software, and to permit persons to whom the Software is furnished to 
do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all 
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
IN THE SOFTWARE.

*/

`default_nettype none
`timescale 1 ns / 1 ps

module np_top (
	input wire [0:0] CLK,
	input wire [0:0] RST, //active low at top level to gpio pin

	output [7:0] LED,

	output FLASH_CSB,
	output FLASH_CLK,
	inout  FLASH_IO0,
	inout  FLASH_IO1,
	inout  FLASH_IO2,
	inout  FLASH_IO3,

	input wire  [0:0] SERIAL_RX,
	output wire [0:0] SERIAL_TX

	);

	wire core_clock;
	assign core_clock = CLK;

	//self reset currently set to 128 cycles
	//Note! Self reset care must be taken so there is enough time for
	//other components to initialize
	reg [7:0] reset_counter = 8'h00;
	wire reset_core;
	assign reset_core = ~reset_counter[7];
	`define RESET_TIME 8'd128
	always @ (posedge core_clock) begin
	    if (RST == 0) begin
	        reset_counter <= 0;
	    end else begin
	        if (reset_counter == `RESET_TIME) begin
	            //nothing to do, reset time reached
	        end else begin
	            reset_counter <= reset_counter + 1;
	        end
	    end
	end

//*****************************PICOSOC soft cpu********************************
	wire        iomem_valid;
	reg         iomem_ready;
	wire [3:0]  iomem_wstrb;
	wire [31:0] iomem_addr;
	wire [31:0] iomem_wdata;
	reg  [31:0] iomem_rdata;

	wire cpu_reset; assign cpu_reset = ~reset_core;
	wire flash_io0_oe, flash_io0_do, flash_io0_di;
	wire flash_io1_oe, flash_io1_do, flash_io1_di;
	wire flash_io2_oe, flash_io2_do, flash_io2_di;
	wire flash_io3_oe, flash_io3_do, flash_io3_di;

	//******************************gpio controller****************************
		reg [31:0] gpio;
		assign LED = gpio;

		always @(posedge core_clock) begin
			if (reset_core) begin
				gpio <= 0;
			end else begin
				iomem_ready <= 0;
				if (iomem_valid && !iomem_ready && iomem_addr[31:24] == 8'h 03)
				begin
					iomem_ready <= 1;
					iomem_rdata <= gpio;
					if (iomem_wstrb[0]) gpio[ 7: 0] <= iomem_wdata[ 7: 0];
					if (iomem_wstrb[1]) gpio[15: 8] <= iomem_wdata[15: 8];
					if (iomem_wstrb[2]) gpio[23:16] <= iomem_wdata[23:16];
					if (iomem_wstrb[3]) gpio[31:24] <= iomem_wdata[31:24];
				end
			end
		end
	//****************************end gpio controller**************************
	
	picosoc cpu (
		.clk (core_clock),
		.resetn (cpu_reset),

		.iomem_valid (iomem_valid),
		.iomem_ready (iomem_ready),
		.iomem_wstrb (iomem_wstrb),
		.iomem_addr  (iomem_addr),
		.iomem_wdata (iomem_wdata),
		.iomem_rdata (iomem_rdata),

		.irq_5 (1'b0),
		.irq_6 (1'b0),
		.irq_7 (1'b0),

		.ser_tx ( SERIAL_TX ),
		.ser_rx ( SERIAL_RX ),

		.flash_csb (FLASH_CSB),
		.flash_clk (FLASH_CLK),

		.flash_io0_oe (flash_io0_oe),
		.flash_io1_oe (flash_io1_oe),
		.flash_io2_oe (flash_io2_oe),
		.flash_io3_oe (flash_io3_oe),

		.flash_io0_do (flash_io0_do),
		.flash_io1_do (flash_io1_do),
		.flash_io2_do (flash_io2_do),
		.flash_io3_do (flash_io3_do),

		.flash_io0_di (flash_io0_di),
		.flash_io1_di (flash_io1_di),
		.flash_io2_di (flash_io2_di),
		.flash_io3_di (flash_io3_di)
	);

	//Tri state buffer for flash IO.
	SB_IO #(
		.PIN_TYPE(6'b 1010_01),
		.PULLUP(1'b 0)
	) flash_io_buf [3:0] (
		.PACKAGE_PIN({FLASH_IO3, FLASH_IO2, FLASH_IO1, FLASH_IO0}),
		.OUTPUT_ENABLE({flash_io3_oe, flash_io2_oe, flash_io1_oe, 
			flash_io0_oe}),
		.D_OUT_0({flash_io3_do, flash_io2_do, flash_io1_do, flash_io0_do}),
		.D_IN_0({flash_io3_di, flash_io2_di, flash_io1_di, flash_io0_di})
	);

//**************************PICOSOC soft cpu*******************************

endmodule
`default_nettype wire