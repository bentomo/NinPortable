//This is the top Module for the gamecube controller_reset
//It instantiates the interface and command responses for 
//interfacing with a gamecube or wii

//Improvements to be made:
//Special functions and firmware

//<><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//**** This module Declaration ***************************
//********************************************************
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><>
    module gc_cont_top (
    
        //interface from one_wire_GC_intf
        input PRE_PLL_CLK, //12MHZ clk input
        input RESET, //master reset
        
        //inputs from buttons
        input START,
        input Y,
        input X,
        input B,
        input A,
        input L,
        input R,
        input Z,
        input DU,
        input DD,
        input DR,
        input DL,
        input DIGITAL_L,
        input DIGITAL_R,
        input ANALOG_JX,
        //input ANALOG_JY,
        //input ANALOG_CX,
        //input ANALOG_CY,
        
        inout GC_BUS,
        
        output JX_RC_CNTL,
        //output JY_RC_CNTL,
        //output CX_RC_CNTL,
        //output CY_RC_CNTL,
        
        output [1:0] RUMBLE,
        
        output SANITY
    );

//<><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//**** This level wires, signals, and parms **************
//********************************************************
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><>
    
    //might need to be moved to upper module when instantiated
    //comparator results from LVDS inputs on FPGA
    wire jxcomp; 
    wire jycomp;
    wire cxcomp;
    wire cycomp;
    wire CLK; //40mhz clk from pll
    wire gc_bus_rd;

    //top level wiring
    wire [79:0] tx_buffer;
    wire [7:0] tx_bit_total;
    wire cmd_done;
    wire bus_control;
    wire [1:0] rumble;
    wire controller_reset;
    wire [23:0] command;
    wire new_command;
    wire [7:0] joystickX;
    wire [7:0] joystickY;
    wire [7:0] cstickX;
    wire [7:0] cstickY;
    
    //sanity logic to see led cycling every second
    reg [31:0] sanity_timer;
    reg sanity;
    
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//**** This level logic **********************************
//********************************************************
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><>

    //inout logic for bus
    //NEVER DRIVE THE BUS HIGH!!! PREVENTS SHORTS INCASE OF OUTPUT TO OUTPUT
    assign GC_BUS = (bus_control == 1'b0) ? 1'b0 : 1'bz;
    assign gc_bus_rd = GC_BUS;
    assign RUMBLE = rumble;
    assign CON_RESET = controller_reset;
	assign SANITY = sanity;
		
    always @( posedge CLK) begin
    
        sanity_timer <= sanity_timer + 1;
        if ( sanity_timer == 32'h09896800 ) begin 
            if ( sanity ) begin
                sanity <= 1'b0;
            end else begin
                sanity <= 1'b1;
            end
            sanity_timer <= 0;
        end
    
    end
    
    
    //Differential input
    defparam DIFF_IN_JX.PIN_TYPE = 6'b000001 ; // {NO_OUTPUT, PIN_INPUT}
    defparam DIFF_IN_JX.IO_STANDARD = "SB_LVDS_INPUT" ;
    SB_IO DIFF_IN_JX (
        .PACKAGE_PIN( ANALOG_JX ),
        .D_IN_0 (jxcomp),
        .D_OUT_0           ( 1'b0 ),
        .D_OUT_1           ( 1'b0 )
    );
    /*
    //Differential input
    defparam DIFF_IN_JY.PIN_TYPE = 6'b000001 ; // {NO_OUTPUT, PIN_INPUT}
    defparam DIFF_IN_JY.IO_STANDARD = "SB_LVDS_INPUT" ;
    SB_IO DIFF_IN_JY (
        .PACKAGE_PIN(ANALOG_JY),
        .D_IN_0 (jycomp),
        .D_OUT_0           ( 1'b0 ),
        .D_OUT_1           ( 1'b0 )
    );
    
    //Differential input
    defparam DIFF_IN_CX.PIN_TYPE = 6'b000001 ; // {NO_OUTPUT, PIN_INPUT}
    defparam DIFF_IN_CX.IO_STANDARD = "SB_LVDS_INPUT" ;
    SB_IO DIFF_IN_CX (
        .PACKAGE_PIN(ANALOG_CX),
        .D_IN_0 (cxcomp),
        .D_OUT_0           ( 1'b0 ),
        .D_OUT_1           ( 1'b0 )
    );
    
    //Differential input
    defparam DIFF_IN_CY.PIN_TYPE = 6'b000001 ; // {NO_OUTPUT, PIN_INPUT}
    defparam DIFF_IN_CY.IO_STANDARD = "SB_LVDS_INPUT" ;
    SB_IO DIFF_IN_CY (
        .PACKAGE_PIN(ANALOG_CY),
        .D_IN_0 (cycomp),
        
        .D_OUT_0           ( 1'b0 ),
        .D_OUT_1           ( 1'b0 )
        
    );
    */

//<><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//**** Sub-Modules ***************************************
//********************************************************
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><>

    gc_cont_top_pll PLL(
        .REFERENCECLK ( PRE_PLL_CLK ),
        .PLLOUTGLOBAL ( CLK ),
        .RESET        ( RESET )
    );
                                     
    one_wire_GC_intf GC_INTF (
        .RESET        ( RESET ),
        .CONTROLLER_RESET ( controller_reset ),
        .CLK          ( CLK ),
        .TX_BUFFER    ( tx_buffer ),
        .TX_BIT_TOTAL ( tx_bit_total ),
        .CMD_DONE     ( cmd_done ),
        .COMMAND      ( command  ),
        .NEW_COMMAND  ( new_command ),
        .GC_BUS_IN    ( gc_bus_rd ),
        .GC_BUS_OUT   ( bus_control )
    );

    gc_cmd_handler CMD_RESP (
        .RESET        ( RESET ),
        .CONTROLLER_RESET ( controller_reset ),
        .CLK          ( CLK   ),
        .COMMAND      ( command ),
        .NEW_COMMAND  ( new_command ),
        .BUTTONS      ( {3'b000, START, Y, X, B, A, 1'b1, L, R, Z, DU, DD, DR, DL} ),
        .DIGITAL_R    ( DIGITAL_R ),
        .DIGITAL_L    ( DIGITAL_L ),
        .J_STICK_X    ( 8'h7F ), //joystickX ),
        .J_STICK_Y    ( 8'h7F ), //joystickY ),
        .C_STICK_X    ( 8'h7F ), //cstickX ),
        .C_STICK_Y    ( 8'h7F ), //cstickY ),
        
        .TX_BIT_TOTAL ( tx_bit_total ),
        .TX_BUFFER    ( tx_buffer ),
        .RUMBLE       ( rumble ),
        .CMD_DONE     ( cmd_done )
    );
    
    adc_sar JOYSTICK_X_ADC (
        .RESET   ( RESET ),
        .CLK     ( CLK ),
        .comp_in ( jxcomp ),
        .RC_CNTL ( JX_RC_CNTL ),
        .DIGITAL_OUT ( joystickX )
    );
    /*
    adc_sar JOYSTICK_Y_ADC (
        .RESET   ( RESET ),
        .CLK     ( CLK ),
        .comp_in ( jycomp ),
        .RC_CNTL ( JY_RC_CNTL ),
        .DIGITAL_OUT ( joystickY )
    );
    
    adc_sar CSTICK_X_ADC (
        .RESET   ( RESET ),
        .CLK     ( CLK ),
        .comp_in ( cxcomp ),
        .RC_CNTL ( CX_RC_CNTL ),
        .DIGITAL_OUT ( cstickX )
    );
    
    adc_sar CSTICK_Y_ADC (
        .RESET   ( RESET ),
        .CLK     ( CLK ),
        .comp_in ( cycomp ),
        .RC_CNTL ( CY_RC_CNTL ),
        .DIGITAL_OUT ( cstickY )
    );
    */
endmodule