
`timescale 1ns/10ps

module ninVideo_tb;

//flag defines
`define NON_INTERLACED    0
`define SCREEN_MODE       1
`define COLOR_BURST_BLANK 2
`define COLOR_BURST_FLAG  3
`define HORIZONTAL_SYNC   4
`define VERTICAL_SYNC     5
`define ODD_FIELD         6
`define COMPOSITE_SYNC    7

localparam h_blank_pixels = 'd2;
localparam v_blank_pixels = 'd2;
localparam h_pixels = 'd640;
localparam v_pixels = 'd480;

logic clk_54mhz;
logic csel;

logic [7:0] VData, y1, y2, Cr, Cb, flags;

initial begin
	clk_54mhz = 0;
	csel = 0;
	y1 = 'd67;
	y2 = 'd67;
	Cr = 'd147;
	Cb = 'd131;
end

always #18.518 clk_54mhz = ~clk_54mhz;

toplevel_withrgb gc_video (

		.VClock ( clk_54mhz ),
		.VData  ( VData     ),
		.CSel   ( csel      ),
		.LRCK  ( 1'b0 ),
		.BCLK  ( 1'b0 ),
		.ADATA ( 1'b0 ),

		.RGBSelect ( 1'b1 )

	);

//tb control logic
typedef enum logic [15:0] {h_blanking, display, v_blanking} state;

//states to change VData
always @ (posedge clk_54mhz) begin

	if ( state == h_blanking) begin

	end else if (state == display) begin

	end else if (state == v_blanking) begin

	end

end

logic [3:0] pixel_info_counter = 0;

always @ (posedge clk_54mhz) begin
	case (pixel_info_counter):
		0: begin

		end // 0:
		1: begin

		end // 1:
		2: begin

		end // 2:
		3: begin

		end // 3:
		4: begin

		end // 4:
end

endmodule