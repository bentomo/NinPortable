/*
 *	THIS FILE WAS COPIED AND MODIFIED FROM hx8kdemo_tb.v
 *
 *  PicoSoC - A simple example SoC using PicoRV32
 *
 *  Copyright (C) 2017  Clifford Wolf <clifford@clifford.at>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

`default_nettype none
`timescale 1 ns / 1 ps

`ifndef VERILATOR
module np_top_tb ();

	reg clk;
	always #5 clk = (clk === 1'b0);

	localparam ser_half_period = 53;
	event ser_sample;

	initial begin
		$dumpfile("np_top_tb.vcd");
		$dumpvars(0, np_top_tb);

		repeat (6) begin
			repeat (50000) @(posedge clk);
			$display("+50000 cycles");
		end
		$finish;
	end

	integer cycle_cnt = 0;

	always @(posedge clk) begin
		cycle_cnt <= cycle_cnt + 1;
	end

	wire ser_rx;
	wire ser_tx;

`else

module np_top_tb (
		input wire [0:0] CLK,
		input wire [0:0] RST,

		input wire  [0:0] SERIAL_RX,
		output wire [0:0] SERIAL_TX
	);

	wire clk;
	assign clk = CLK;

	wire ser_rx; assign ser_rx = SERIAL_RX;
	wire ser_tx; assign SERIAL_TX = ser_tx;


`endif

	wire [7:0] leds;

	wire flash_csb;
	wire flash_clk;
	wire flash_io0;
	wire flash_io1;
	wire flash_io2;
	wire flash_io3;
	//pullup(flash_io0);
	//pullup(flash_io1);
	//pullup(flash_io2);
	//pullup(flash_io3);

`ifndef VERILATOR
	always @(leds) begin
		#1 $display("%b", leds);
	end
`endif

	np_top DUT (
		.CLK       (clk      ),
		.RST 	   (1'b1     ),
		.LED       (leds     ),
		.SERIAL_RX (ser_rx   ),
		.SERIAL_TX (ser_tx   ),
		.FLASH_CSB (flash_csb),
		.FLASH_CLK (flash_clk),
		.FLASH_IO0 (flash_io0),
		.FLASH_IO1 (flash_io1),
		.FLASH_IO2 (flash_io2),
		.FLASH_IO3 (flash_io3)
	);

	spiflash spiflash_model (
		.csb(flash_csb),
		.clk(flash_clk),
		.io0(flash_io0),
		.io1(flash_io1),
		.io2(flash_io2),
		.io3(flash_io3)
	);

`ifndef VERILATOR
	reg [7:0] buffer;

	always begin
		@(negedge ser_tx);

		repeat (ser_half_period) @(posedge clk);
		-> ser_sample; // start bit

		repeat (8) begin
			repeat (ser_half_period) @(posedge clk);
			repeat (ser_half_period) @(posedge clk);
			buffer = {ser_tx, buffer[7:1]};
			-> ser_sample; // data bit
		end

		repeat (ser_half_period) @(posedge clk);
		repeat (ser_half_period) @(posedge clk);
		-> ser_sample; // stop bit

		if (buffer < 32 || buffer >= 127)
			$display("Serial data: %d", buffer);
		else
			$display("Serial data: '%c'", buffer);
	end
`endif

endmodule
`default_nettype wire