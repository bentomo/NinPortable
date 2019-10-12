//This module handles the commands received
//from the one_wire_GC_intf and generates
//the correct response

//Improvements to be made:
//A lot of regs can be reduced in size

//<><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//**** This module instantiation *************************
//********************************************************
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><>
    module gc_cmd_handler #(
        parameter TX_BUFFER_WIDTH = 8'd80
    )(
    
        //interface from one_wire_GC_intf
        input CLK, //40MHZ clk input
        input RESET, //master reset
        input [23:0] COMMAND,
        input NEW_COMMAND,
        
        //inputs from buttons
        input [15:0] BUTTONS, //defined as 0 0 0 S Y X B A  1 L R Z DU DD DR DL
        input DIGITAL_R,
        input DIGITAL_L,
        input [7:0] J_STICK_X,
        input [7:0] J_STICK_Y,
        input [7:0] C_STICK_X,
        input [7:0] C_STICK_Y,
        
        output [7:0] TX_BIT_TOTAL, //amount of bits in response buffer to write back to master
        output [TX_BUFFER_WIDTH-1:0] TX_BUFFER, //up to 10 byte response
        output [1:0] RUMBLE,
        output CMD_DONE, //at 40MHZ commands have up to 240 cycles to finish command
                         //this can possibly be increased for custom firmware
                        
        output CONTROLLER_RESET //self reset in case of receiving garbage
    
    );
    
    
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//**** This level wires, signals, and parms **************
//********************************************************
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><>
    
    //parameters
    parameter [23:0] ID_VECTOR = 24'h090030; //typical ID response for official controller
    parameter [79:0] RECAL = 80'h00808080808000000000; //typical recal response
    
    //output control
    reg [TX_BUFFER_WIDTH-1:0] tx_buffer;
    reg [7:0] tx_bit_total;
    reg [1:0] rumble;
    reg [23:0] command; //bits 7:2 are unused for now and will be synthesized out
    reg [2:0] cmd_done_counter;
    reg cmd_done;
    wire [7:0] analog_r;
    wire [7:0] analog_l;
    wire [15:0] joystick;
    
    //the debouncer inverts the logic, buttons are active low on PCB
    //but will report 1 when pressed
    wire debouncedDigital_r;
    wire debouncedDigital_l;
    wire [15:0] debouncedButtons;
    
    //combinational logic vectors
    reg [7:0] tx_B4;
    reg [7:0] tx_B5;
    reg [7:0] tx_B6;
    reg [7:0] tx_B7;
    
    //state machine control
    reg [3:0] cont_state;
	reg con_reset;
    

//<><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//**** This level logic **********************************
//********************************************************
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><>

    assign TX_BUFFER = tx_buffer;
    assign TX_BIT_TOTAL = tx_bit_total;
    assign CMD_DONE = cmd_done;
    assign joystick = {J_STICK_X,J_STICK_Y};
    assign RUMBLE = rumble;
	assign CONTROLLER_RESET = con_reset;
	assign debouncedButtons[15 -: 3] = 3'b000;
	assign debouncedButtons[7] = 1'b1;
    
    //analog triggers are active low e.g. full depressed is 0x00
    assign analog_r = (debouncedDigital_r) ? 8'h00 : 8'hFF;
    assign analog_l = (debouncedDigital_l) ? 8'h00 : 8'hFF;

    always @( posedge CLK ) begin
        if ( !RESET || con_reset ) begin
        
            //reset regs
            tx_buffer <= 0;
            tx_bit_total <= 0;
            command <= 0;
            cmd_done <= 0;
            rumble <= 0;
            cmd_done_counter <= 0;

            //reset state machine
            cont_state <= 0;
			con_reset <= 0;
            
        end else begin
            
            //state 0: idle state
            if ( cont_state == 4'h0 ) begin
                if ( NEW_COMMAND ) begin
                    command <= COMMAND;
                    cont_state <= 4'h1; //move to handle command state
                end
            end else
            
            //state 1: handle command - determine next steps
            if ( cont_state == 4'h1 ) begin
            
                //get ID
                if ( command[23 -: 8] == 8'h00 || command[23 -: 8] == 8'hFF ) begin
                    //respond with predefined vector
                    tx_buffer[TX_BUFFER_WIDTH-1 -: 24] <= ID_VECTOR; 
                    tx_bit_total <= 'd24;
                    cmd_done <= 1'b1;
                    cont_state <= 4'hF; //move to cmd_done state
                end else if ( command[23 -: 8] == 8'h41 || command[23 -: 8] == 8'h42 ) begin //recalibrate
                    //respond with predefined vector
                    //tx_buffer[TX_BUFFER_WIDTH-1 -: 80] <= RECAL;
                    tx_buffer <= RECAL;
                    tx_bit_total <= 'd80;
                    cmd_done <= 1'b1;
                    cont_state <= 4'hF; //move to cmd_done state
                end else if ( command[23 -: 8] == 8'h40 ) begin //get button states
                    tx_buffer[TX_BUFFER_WIDTH-1 -: 64] <= {debouncedButtons, joystick, tx_B4, tx_B5, tx_B6, tx_B7};
                    tx_bit_total <= 'd64;
                    rumble <= command [1:0];
                    cmd_done <= 1'b1;
                    cont_state <= 4'hF; //move to cmd_done state
                end else begin
					//garbage was received in the command buffer
					//respond with zeros
					//con_reset <= 1'b1;
                    tx_buffer[TX_BUFFER_WIDTH-1 -: 64] <= 0;
                    tx_bit_total <= 'd64;
                    rumble <= command [1:0];
                    cmd_done <= 1'b1;
                    cont_state <= 4'hF; //move to cmd_done state
				end
                
            end else
            
            //state F: command_done must deassert cmd_done before
            //returning to idle state
            if ( cont_state == 4'hF ) begin
                
                //give 7 clocks do deassert cmd done
                if ( cmd_done_counter == 3'b111 ) begin
                    cmd_done_counter <= 0;
                    cmd_done <= 1'b0;
                    cont_state <= 4'h0; //return to idle state
                end else begin
                    cmd_done_counter <= cmd_done_counter + 1;
                end                
                
            end
            
        end
    end
    
    //combinational logic for analog mode
    always @( * ) begin
        //analog mode 0, 5, 6, 7
        if ( command[15:8] == 8'h00 || command[15:8] == 8'h05 || command[15:8] == 8'h06 || command[15:8] == 8'h07 ) begin
            tx_B4 = C_STICK_X;
            tx_B5 = C_STICK_Y;
            tx_B6 = ((analog_l & 8'hF0) | (analog_r >> 4));
            tx_B7 = 8'h00; //(AA & 0xF0) | (AB >> 4) is the logic but AA and AB are 0x00
        end else if ( command[15:8] == 8'h01 ) begin //analog mode 1
            tx_B4 = ((C_STICK_X & 8'hF0) | (C_STICK_Y >> 4));
            tx_B5 = analog_l;
            tx_B6 = analog_r;
            tx_B7 = 8'h00; //(AA & 0xF0) | (AB >> 4) is the logic but AA and AB are 0x00
        end else if ( command[15:8] == 8'h02 ) begin //analog mode 2
            tx_B4 = ((C_STICK_X & 8'hF0) | (C_STICK_Y >> 4));
            tx_B5 = ((analog_l & 8'hF0) | (analog_r >> 4));
            tx_B6 = 8'h00; //AA is the logic but AA and AB are 0x00
            tx_B7 = 8'h00; //AB is the logic but AA and AB are 0x00
        end else if ( command[15:8] == 8'h03 ) begin //analog mode 3
            tx_B4 = C_STICK_X;
            tx_B5 = C_STICK_Y;
            tx_B6 = analog_l;
            tx_B7 = analog_r;
        end else if ( command[15:8] == 8'h04 ) begin //analog mode 4
            tx_B4 = C_STICK_X;
            tx_B5 = C_STICK_Y;
            tx_B6 = 8'h00; //logic is AA but AA is 0x00
            tx_B7 = 8'h00; //logic is AB but AB is 0x00
        end else begin
            tx_B4 = 8'h00;
            tx_B5 = 8'h00;
            tx_B6 = 8'h00;
            tx_B7 = 8'h00;
        end
        
    end
	
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//**** Sub-Modules ***************************************
//********************************************************
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><>
	
	//buttons are defined as 0 0 0 S Y X B A  1 L R Z DU DD DR DL
	//Start Button
	tactile_sw_debouncer Start_DBNC (
		.RESET ( RESET ),
		.CLK   ( CLK ),
		.PB	   ( BUTTONS[12] ),
		.DEBOUNCED ( debouncedButtons[12] )
	);
	
	//Y button
	tactile_sw_debouncer Y_DBNC (
		.RESET ( RESET ),
		.CLK   ( CLK ),
		.PB	   ( BUTTONS[11] ),
		.DEBOUNCED ( debouncedButtons[11] )
	);
	
	//X button
	tactile_sw_debouncer X_DBNC (
		.RESET ( RESET ),
		.CLK   ( CLK ),
		.PB	   ( BUTTONS[10] ),
		.DEBOUNCED ( debouncedButtons[10] )
	);
	
	//B button
	tactile_sw_debouncer B_DBNC (
		.RESET ( RESET ),
		.CLK   ( CLK ),
		.PB	   ( BUTTONS[9] ),
		.DEBOUNCED ( debouncedButtons[9] )
	);
	
	//A button
	tactile_sw_debouncer A_DBNC (
		.RESET ( RESET ),
		.CLK   ( CLK ),
		.PB	   ( BUTTONS[8] ),
		.DEBOUNCED ( debouncedButtons[8] )
	);
	
	//L button
	tactile_sw_debouncer L_DBNC (
		.RESET ( RESET ),
		.CLK   ( CLK ),
		.PB	   ( BUTTONS[6] ),
		.DEBOUNCED ( debouncedButtons[6] )
	);
	
	//R button
	tactile_sw_debouncer R_DBNC (
		.RESET ( RESET ),
		.CLK   ( CLK ),
		.PB	   ( BUTTONS[5] ),
		.DEBOUNCED ( debouncedButtons[5] )
	);
	
	//Z button
	tactile_sw_debouncer Z_DBNC (
		.RESET ( RESET ),
		.CLK   ( CLK ),
		.PB	   ( BUTTONS[4] ),
		.DEBOUNCED ( debouncedButtons[4] )
	);
	
	//DU button
	tactile_sw_debouncer DU_DBNC (
		.RESET ( RESET ),
		.CLK   ( CLK ),
		.PB	   ( BUTTONS[3] ),
		.DEBOUNCED ( debouncedButtons[3] )
	);
	
	//DD button
	tactile_sw_debouncer DD_DBNC (
		.RESET ( RESET ),
		.CLK   ( CLK ),
		.PB	   ( BUTTONS[2] ),
		.DEBOUNCED ( debouncedButtons[2] )
	);
	
	//DR button
	tactile_sw_debouncer DR_DBNC (
		.RESET ( RESET ),
		.CLK   ( CLK ),
		.PB	   ( BUTTONS[1] ),
		.DEBOUNCED ( debouncedButtons[1] )
	);
	
	//DL button
	tactile_sw_debouncer DL_DBNC (
		.RESET ( RESET ),
		.CLK   ( CLK ),
		.PB	   ( BUTTONS[0] ),
		.DEBOUNCED ( debouncedButtons[0] )
	);
	
	//DAC L Trigger
	tactile_sw_debouncer digital_L_DBNC (
		.RESET ( RESET ),
		.CLK   ( CLK ),
		.PB	   ( DIGITAL_L ),
		.DEBOUNCED ( debouncedDigital_l )
	);
	
	//DAC R Trigger
	tactile_sw_debouncer digital_R_DBNC (
		.RESET ( RESET ),
		.CLK   ( CLK ),
		.PB	   ( DIGITAL_R ),
		.DEBOUNCED ( debouncedDigital_r )
	);
	

endmodule
    

    
    
    