/*

top level wrapper for FPGA design

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

`timescale 1 ns / 1 ps

module top_np(
	input wire CLK,
	input wire RST,

	

	input wire SERIAL_RX,
	output reg SERIAL_TX

	);

	wire core_clock;
	assign core_clock <= CLK;

	//self reset
	reg [7:0] reset_counter;
	assign reset_core = ~reset_counter[7];
	`define RESET_TIME 'b100
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

	wire cpu_reset; assign cpu_reset ~= reset_core;
	picosoc cpu (
		.clk (core_clock),
		.resetn (cpu_reset),

		.iomem_valid (),
		.iomem_ready (),
		.iomem_wstrb (),
		.iomem_addr (),
		.iomem_wdata (),
		.iomem_rdata (),

		.irq_5 (),
		.irq_6 (),
		.irq_7 (),

		.ser_tx ( SERIAL_TX ),
		.ser_rx ( SERIAL_RX ),

		.flash_csb (),
		.flash_clk (),

		.flash_io0_oe (),
		.flash_io1_oe (),
		.flash_io2_oe (),
		.flash_io3_oe (),

		.flash_io0_do (),
		.flash_io1_do (),
		.flash_io2_do (),
		.flash_io3_do (),

		.flash_io0_di (),
		.flash_io1_di (),
		.flash_io2_di (),
		.flash_io3_di ()
	);


endmodule