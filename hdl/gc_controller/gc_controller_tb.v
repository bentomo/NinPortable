    `timescale 1 ns / 1 ns

    module gc_controller_tb;

    /* Test case scenario */
    reg reset = 0;
    reg master_en = 0;
    initial begin
     $dumpfile("gc_simout.vcd");
     $dumpvars;//(clk, reset, analog_value, capacitor_value, rc_cntl, digital_value);

     # 100 reset = 1; //at 100ns come out of reset
        
     //<><><><><><><><><><><><><><><>
     //GET ID COMMAND
     //<><><><><><><><><><><><><><><>
     # 1000 master_en = 0; //at 1us assert low start bit stream
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 1000 master_en = 1;
     //<><><><><><><><><><><><><><><>
     //END GET ID COMMAND
     //<><><><><><><><><><><><><><><> 
     
     #200000 //delay to receive cmd
     
     //<><><><><><><><><><><><><><><>
     //RECALIBRATE COMMAND 0x41
     //<><><><><><><><><><><><><><><>
     # 1000 master_en = 0; //at 1us assert low start bit stream
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 1000 master_en = 1; //1
     # 3000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 1000 master_en = 1; //1
     # 3000 master_en = 0;
     
     # 1000 master_en = 1;
     //<><><><><><><><><><><><><><><>
     //END RECALIBRATE COMMAND 0x41
     //<><><><><><><><><><><><><><><> 
     
     # 400000 //delay 400us to receive recal info
     
     //<><><><><><><><><><><><><><><>
     //RECALIBRATE COMMAND 0x42 AB CD
     //<><><><><><><><><><><><><><><>
     # 1000 master_en = 0; //at 1us assert low start bit stream
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 1000 master_en = 1; //1
     # 3000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 1000 master_en = 1; //1
     # 3000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     //parm 1 0xAB
     # 1000 master_en = 1; //1
     # 3000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 1000 master_en = 1; //1
     # 3000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 1000 master_en = 1; //1
     # 3000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 1000 master_en = 1; //1
     # 3000 master_en = 0;
     
     # 1000 master_en = 1; //1
     # 3000 master_en = 0;
     
     //parm 2 0xCD
     # 1000 master_en = 1; //1
     # 3000 master_en = 0;
     
     # 1000 master_en = 1; //1
     # 3000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 1000 master_en = 1; //1
     # 3000 master_en = 0;
     
     # 1000 master_en = 1; //1
     # 3000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 1000 master_en = 1; //1
     # 3000 master_en = 0;
     
     # 1000 master_en = 1; //stop bit
     //<><><><><><><><><><><><><><><><><><>
     //END RECALIBRATE COMMAND 0x42 AB CD
     //<><><><><><><><><><><><><><><><><><> 
     
     #400000 //delay 400us for response
     
     //<><><><><><><><><><><><><><><>
     //Get Buttons COMMAND 0x40 03 00
     //<><><><><><><><><><><><><><><>
     # 1000 master_en = 0; //at 1us assert low start bit stream
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 1000 master_en = 1; //1
     # 3000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     //parm 1 0x03
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 1000 master_en = 1; //1
     # 3000 master_en = 0;
     
     # 1000 master_en = 1; //1
     # 3000 master_en = 0;
     
     //parm 2 0x03 rumble
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 1000 master_en = 1; //1
     # 3000 master_en = 0;
     
     # 1000 master_en = 1; //1
     # 3000 master_en = 0;
     
     # 1000 master_en = 1; //stop bit
     //<><><><><><><><><><><><><><><><><><>
     //END Get Buttons COMMAND 0x40 03 00
     //<><><><><><><><><><><><><><><><><><>
	 
	 #3000000 //delay 400us for response
     
     //<><><><><><><><><><><><><><><>
     //Get Buttons COMMAND 0x40 03 00
     //<><><><><><><><><><><><><><><>
     # 1000 master_en = 0; //at 1us assert low start bit stream
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 1000 master_en = 1; //1
     # 3000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     //parm 1 0x03
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 1000 master_en = 1; //1
     # 3000 master_en = 0;
     
     # 1000 master_en = 1; //1
     # 3000 master_en = 0;
     
     //parm 2 0x03 rumble
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 3000 master_en = 1; //0
     # 1000 master_en = 0;
     
     # 1000 master_en = 1; //1
     # 3000 master_en = 0;
     
     # 1000 master_en = 1; //1
     # 3000 master_en = 0;
     
     # 1000 master_en = 1; //stop bit
     //<><><><><><><><><><><><><><><><><><>
     //END Get Buttons COMMAND 0x40 03 00
     //<><><><><><><><><><><><><><><><><><>
	 
     # 4000000 $finish; //4 ms
    end

    /* generate 40MHZ clk */
    reg clk = 0;
    //generate clk, 25ns period
    initial begin
        #1 clk = 0;
        forever begin
            #13 clk = ! clk;
        end
    end

    //inputs for the top module
    reg START = 0;
    reg Y = 0;
    reg X = 0;
    reg B = 0;
    reg A = 0;
    reg L = 0;
    reg R = 0;
    reg Z = 0;
    reg DU = 0;
    reg DD = 0;
    reg DR = 0;
    reg DL = 0;
    reg digitalL = 0;
    reg digitalR = 0;
    reg [7:0] joystickX = 8'h7F;
    reg [7:0] joystickY = 8'h7F;
    reg [7:0] cstickX = 8'h7F;
    reg [7:0] cstickY = 8'h7F;
    
    //top level wiring
    wire [79:0] tx_buffer;
    wire [7:0] tx_bit_total;
    wire cmd_done;
    wire bus;
	pullup (bus);
    wire [1:0] rumble;
	wire controller_reset;
    
    //inout logic for bus
	//NEVER DRIVE THE BUS HIGH!!! PREVENTS SHORTS INCASE OF OUTPUT TO OUTPUT
    assign bus = (master_en == 1'b0) ? 1'b0 : 1'bz;

    gc_cont_top CONTROLLER_COMPLETE (
            .RESET ( reset ),
            .CLK   ( clk ),
            .START ( START ),
            .Y (Y),
            .X (X),
            .B  (B),
            .A  (A),
            .L  (L),
            .R  (R),
            .Z  (Z),
            .DU (DU),
            .DD (DD),
            .DR (DR),
            .DL (DL),
            .DIGITAL_L (digitalL),
            .DIGITAL_R (digitalR),
            
            .GC_BUS (bus),
            
            .RUMBLE (rumble)
    
    
    );
    
     // $monitor("At time %t, Digital = %h (%0d)",
              // $time, digital_value, digital_value);
    endmodule // test