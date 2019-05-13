//This module is the one wire slave communication 
//interface for a gamecube controller
//This module only manages the serial protocol

//Improvements to be made:
//A lot of regs can be reduced in size according to what they'll actually count to
//Some states may not be required
//over 24 bit response not recognized
//no special commands implemented

//<><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//**** This module instantiation *************************
//********************************************************
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><>
    module one_wire_GC_intf #(
        parameter TX_BUFFER_WIDTH = 'd80
    )(   
        input CLK, //40MHZ clk input
        input RESET, //master reset
        input CONTROLLER_RESET, //self reset
        input [TX_BUFFER_WIDTH-1:0] TX_BUFFER, //up to 10 byte response
        input [7:0] TX_BIT_TOTAL, //amount of bits in response buffer to write back to master
        input CMD_DONE, //should only be asserted for a few clock cycles by the top module
        input GC_BUS_IN, //the inout port must be placed in the top module for the logic to work
        
        //output command to be handled
        //see the controller protocol.pdf for list of commands
        output [23:0] COMMAND, 
        output NEW_COMMAND, //tells the controller state machine to process command
        
        //bus that will need to be forwarded to top module
        output GC_BUS_OUT //the inout port must be placed in the top module for the logic to work
    
    );
    
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//**** This level wires, signals, and parms **************
//********************************************************
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><>
    
    //output control
    reg gc_bus_out;
    reg [23:0] command;
    reg new_command;
    
    //state machine control
    reg [3:0] comm_state;
    reg [3:0] return_state;
    reg [4:0] rx_bit_counter;
    reg [4:0] prev_rx_bit_counter;
    reg [8:0] rx_timer;
	reg [1:0] sample_counter;
    wire [8:0] rx_timer_shifted;
    reg [8:0] rx_timer_half;
    reg [6:0] rx_timer_full;
    reg [7:0] tx_bit_counter;
    reg [7:0] tx_timer;
    reg [3:0] delay_timer;
    parameter [7:0] tx_4us = 8'd149; //approximately 3.743us at 40MHz
    parameter [7:0] tx_1us = 8'd30;  //approximately 753.7ns at 39.8MHz
    parameter [7:0] tx_3us = 8'd110; //approximately 2.763us at 40MHz
    
    //receive buffer
    reg [23:0] rx_buffer; //3 byte buffer to receive commands

//<><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//**** This level logic **********************************
//********************************************************
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><>

    assign COMMAND = command;
    assign NEW_COMMAND = new_command;
    assign GC_BUS_OUT = gc_bus_out;
    assign rx_timer_shifted = {1'b0, rx_timer [8 -: 8]};
    
    always @( posedge CLK ) begin
        if ( !RESET || CONTROLLER_RESET ) begin
        
            //reset ports
            gc_bus_out <= 1'b1;
            command <= 0;
            new_command <= 0;
            
            //reset state machine
            comm_state <= 0;
            return_state <= 0; //used to delay states that change inout port assignement
            rx_bit_counter <= 'd23;
            prev_rx_bit_counter <= 'd23;
            rx_timer <= 0;
            rx_timer_half <= 0;
            rx_timer_full <= 0;
            rx_buffer <= 24'h000000;
            tx_bit_counter <= 0;
            tx_timer <= 0;  
            delay_timer <= 0;
			sample_counter <= 0;
            
        end
        else begin
            
            //state 0: idle state - sampling for falling edge
            if ( comm_state == 4'h0 ) begin
                if ( GC_BUS_IN == 1'b0 ) begin
					if ( sample_counter == 2'b11 ) begin
						comm_state <= 4'h1; //move to state 1: start RX timer
						sample_counter <= 0;
					end
					else begin
						sample_counter <= sample_counter + 1;
					end
                end 
				else if ( sample_counter > 0 ) begin
					//we only got here if we saw noise
					sample_counter <= 0;
				end
            end else
            
            //state 1: start RX - start rx timer and sample the bus
            if ( comm_state == 4'h1 ) begin
                
                if ( GC_BUS_IN == 1'b1 ) begin
					if ( sample_counter == 2'b11 ) begin
						rx_timer_half <= rx_timer;
						comm_state <= 4'h2; //move to state 2: count RX
						sample_counter <= 0;
					end
					else begin
						sample_counter <= sample_counter + 1;
					end
                end
				else begin
					rx_timer <= rx_timer + 1;
					if ( sample_counter > 0 ) begin
						//we only got here if we saw noise
						sample_counter <= 0; 
					end
				end
                
            end else
            
            //state 2: count RX - continue counting rx timer until second falling edge
            if ( comm_state == 4'h2 ) begin
                
                //prev_rx_bit_counter determines if at end of rx buffer and prevents underrun
                if ( GC_BUS_IN == 1'b0 ) begin
					if ( sample_counter == 2'b11 ) begin
						sample_counter <= 0;
						rx_timer <= 0; //reset rx timer
						
						if (  prev_rx_bit_counter != 0 ) begin
							//moving state 3 into state 2 - test rx bit
							prev_rx_bit_counter <= rx_bit_counter; //prevent underrun
							if ( rx_bit_counter != 0 ) begin
								//I don't like underrunning registers
								rx_bit_counter <= rx_bit_counter - 1; //decrement bit counter
							end
							
							if ( rx_timer_half < rx_timer_shifted ) begin
								rx_buffer[rx_bit_counter] <= 1'b1; //duty cycle greater than %50 bit was a 1
							end else begin
								rx_buffer[rx_bit_counter] <= 1'b0; //duty cycle less than %50 bit was a 0
							end
							
							comm_state <= 4'h1; //move back to state 1 after sampling
							
						end
					end
					else begin
						sample_counter <= sample_counter + 1;
					end
                    
                end
                else if ( rx_timer == 'd255 ) begin
                    comm_state <= 4'h3; //communication done, move to state 3: process command
                    command <= rx_buffer; //output new command
                    new_command <= 1'b1; //assert that new command is received
                    rx_timer <= 0;
					sample_counter <= 0;
                end 
                else begin 
                    rx_timer <= rx_timer + 1;
					if ( sample_counter > 0 ) begin
						//we only got here if we saw noise
						sample_counter <= 0;
					end
                end
                
            end else

            //state 3: process cmd - idle state to wait for command completion
            if ( comm_state == 4'h3 ) begin
                rx_bit_counter <= 'd23; //reset bit counter for next command
                new_command <= 1'b0; //assert new command for only 1 clock cycle
                tx_timer <= 8'h00; //ensure that the tx timer is zero
                prev_rx_bit_counter <= 'd23; //reset prev_rx for next command
                
                if ( CMD_DONE == 1'b1 ) begin
                    comm_state <= 4'h8;
                    return_state <= 4'h4;
                    gc_bus_out <= 1'b0;
                end
                
            end else
            
            //state 4: start TX - start tx timer to 1us to decide what to do
            if ( comm_state == 4'h4 ) begin
                tx_timer <= tx_timer + 1;
                
                if ( tx_timer == tx_1us ) begin
                    comm_state <= 4'h5; //move to state 6: test TX bit
                end
            end else
            
            //state 5: test TX bit - write out 0 or 1
            if ( comm_state == 4'h5 ) begin
                tx_timer <= tx_timer + 1;
                
                if ( TX_BUFFER[TX_BUFFER_WIDTH - 1 - tx_bit_counter] == 1'b1 || tx_timer == tx_3us ) begin
                    comm_state <= 4'h8;
                    return_state <= 4'h6; //move to state 7: assert bit
                    gc_bus_out <= 1'b1;
                    tx_bit_counter <= tx_bit_counter + 1;
                end
            end else
            
            //state 6: assert bit - determine whether or not to continue bit stream 
            if ( comm_state == 4'h6 ) begin
                
                if ( tx_timer == tx_4us ) begin
                    gc_bus_out <= 1'b0;
                    tx_timer <= 8'h00;
                    if ( tx_bit_counter < TX_BIT_TOTAL ) begin
                        return_state <= 4'h4; //more bits to transmit, move back to state 5: start TX
                        comm_state <= 4'h8;
                    end
                    else begin
                        return_state <= 4'h7; //on last bit, move to state 8: stop bit
                        comm_state <= 4'h8;
                    end
                end
                else begin 
                    tx_timer <= tx_timer + 1;
                end
                
            end else
            
            //state 7: stop bit - count another 1us, release bus, and return to idle
            if ( comm_state == 4'h7 ) begin
                tx_bit_counter <= 0; //reset the bit counter now that tx is done
                
                if ( tx_timer == tx_1us ) begin
                    comm_state <= 4'h8; //move to delay state to give gcbus time to release
                    return_state <= 4'h0;
                    gc_bus_out <= 1'b1; //release bus
                    tx_timer <= 8'h00;
                end 
                else begin
                    tx_timer <= tx_timer + 1;
                end
                
            end else
            
            //state 8: delay state - the inout port does not immediately return to an input after asserting gc_bus_out
            if ( comm_state == 4'h8 ) begin
                
                //delay approximately 250ns
                if ( delay_timer == 4'hA) begin
                    comm_state <= return_state; //return to requested state
                    delay_timer <= 4'h0;
                end else begin
                    delay_timer <= delay_timer + 1;
                end
                
            end
            
        end
    end

endmodule
    
    
    
    