//This module debounces push buttons switches
//The input is active low and will output high when a button is pushed

//Improvements to be made:

//<><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//**** This module instantiation *************************
//********************************************************
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><>
module tactile_sw_debouncer (
    
    //interface from one_wire_GC_intf
    input CLK, //40MHZ clk input
    input RESET, //master reset
    
    //inputs from buttons
    input PB, //raw signal from switch
    
    output DEBOUNCED, //debounced signal
	output PB_DOWN,	//1 for 1 clock cycle when button is pushed
	output PB_UP	//1 for 1 clock cycle when button is released
    
    );
    
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//**** This level wires, signals, and parms **************
//********************************************************
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><>
    
    //parameters
    reg debounced;
	wire sync_0;
	wire sync_1;
	reg [16:0] counter; //a 17 bit counter will max out around 3ms
    
	wire counter_max = &counter; //1 when the timer overflows
	wire idle = ( debounced==sync_1 );

//<><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//**** This level logic **********************************
//********************************************************
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><>
	assign DEBOUNCED = debounced;
	assign PB_DOWN = ~idle & counter_max & ~debounced;
	assign PB_UP = ~idle & counter_max & debounced;
    assign sync_0 = ~PB;
	assign sync_1 = sync_0; 

    always @( posedge CLK ) begin
        if ( !RESET ) begin
        
            //reset regs
			debounced <= 0;
			counter <= 0;
            
        end
        else begin
			if ( idle ) begin
				counter <= 0; 
			end
			else begin
				counter <= counter + 1;
				if ( counter_max ) begin
					debounced <= ~debounced;
				end
			end
			
		end
    end

endmodule
    
    
    
    