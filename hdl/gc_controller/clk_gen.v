module clk_gen(PACKAGEPIN,
               PLLOUTCORE,
               PLLOUTGLOBAL,
               RESET);

input PACKAGEPIN;
input RESET;    /* To initialize the simulation properly, the RESET signal (Active Low) must be asserted at the beginning of the simulation */ 
output PLLOUTCORE;
output PLLOUTGLOBAL;

SB_PLL40_PAD clk_gen_inst(.PACKAGEPIN(PACKAGEPIN),
                          .PLLOUTCORE(PLLOUTCORE),
                          .PLLOUTGLOBAL(PLLOUTGLOBAL),
                          .EXTFEEDBACK(),
                          .DYNAMICDELAY(),
                          .RESETB(RESET),
                          .BYPASS(1'b0),
                          .LATCHINPUTVALUE(),
                          .LOCK(),
                          .SDI(),
                          .SDO(),
                          .SCLK());

//\\ Fin=54, Fout=40;
defparam clk_gen_inst.DIVR = 4'b0100;
defparam clk_gen_inst.DIVF = 7'b0111010;
defparam clk_gen_inst.DIVQ = 3'b100;
defparam clk_gen_inst.FILTER_RANGE = 3'b001;
defparam clk_gen_inst.FEEDBACK_PATH = "SIMPLE";
defparam clk_gen_inst.DELAY_ADJUSTMENT_MODE_FEEDBACK = "FIXED";
defparam clk_gen_inst.FDA_FEEDBACK = 4'b0000;
defparam clk_gen_inst.DELAY_ADJUSTMENT_MODE_RELATIVE = "FIXED";
defparam clk_gen_inst.FDA_RELATIVE = 4'b0000;
defparam clk_gen_inst.SHIFTREG_DIV_MODE = 2'b00;
defparam clk_gen_inst.PLLOUT_SELECT = "GENCLK";
defparam clk_gen_inst.ENABLE_ICEGATE = 1'b0;

endmodule
