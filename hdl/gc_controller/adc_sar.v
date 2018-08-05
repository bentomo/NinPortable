//this file is the framework for an SAR ADC used on differential inputs of an FPGA
//testing model for this logic
//  TODO:
//  step 1. Test LVDS instantiation and synthesis in icecube2
//       2. Wire parallel digital output to LEDs for testing on dev board
//       3. Take top level logic and modularlize it in a piece of logic
//       4. test modularized logic heavily for reuse later


//<><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//**** This module instantiation *************************
//********************************************************
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><>
    module adc_sar #(
        parameter half_charge_time = 8'd130,
        parameter discharge_time = 8'd255
    )(
    
        input RESET, //reset signal, does not reset ADC output
        
        input comp_in,
        
        input CLK, //40MHZ input from pll, may be different if running from dev board
        
        output RC_CNTL,
        output [7:0] DIGITAL_OUT //digital result

    );
    
    
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//**** This level wires, signals, and parms **************
//********************************************************
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><>
    
    //counters
    reg [3:0]   bit_counter; //count 8 bits of sample
    reg [7:0]   sample_reg; //temporary sample
    reg [7:0]   ADC_reg_out; //final value of SAR analog to digital conversion
    reg [7:0]   charge_time; //initially is half charge time and is halved with each bit sample
    reg [7:0]   charge_counter; //timer register for counting and timing
    
    reg         discharging_cap; //value to wait for to discharge cap on reset
    reg         NEW_ADC_SAMPLE; //alert to start a new sample cycle
    reg         rc_cntl;
    
    //for 1kOhm R and 4.7nF cap half charge time is 3.25us
    //discharge is given 5us
    //parameter [7:0] half_charge_time = 'd130; //FIXME half of total charge time for RC network, changes depending on cap, res, VCCIO, and clk speed
    //parameter [7:0] discharge_time = 'd255; //FIXME discharge time required to run to reset RC network, changes depending on cap, res, VCCIO, and clk speed

//<><><><><><><><><><><><><><><><><><><><><><><><><><><><>
//**** This level logic **********************************
//********************************************************
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><>

    assign DIGITAL_OUT = ADC_reg_out;
    assign RC_CNTL = rc_cntl;
    
    always @( posedge CLK ) begin
        if ( !RESET || NEW_ADC_SAMPLE ) begin
            //reset all counters to take a new sample
            bit_counter <= 0;
            rc_cntl <= 0;
            sample_reg <= 0;
            
            discharging_cap <= 1'b1;
            charge_time <= half_charge_time;
            
            discharging_cap <= 1'b1; //this ensures the cap is discharged on startup
            charge_counter <= discharge_time;
            
            NEW_ADC_SAMPLE <= 1'b0;
            
            
            if ( !RESET && !NEW_ADC_SAMPLE ) begin //total logic reset
                ADC_reg_out <= 8'h00;
                NEW_ADC_SAMPLE <= 1'b1;
            end
            
        end
        else begin
            if ( !discharging_cap ) begin //start the sampling logic if not waiting for a cap discharge
                
                //sample 8 bits, then sample 4 times
                if ( charge_counter > 0 ) begin
                    charge_counter <= charge_counter - 1;
                end
                
                //state conditions
                if ( charge_counter == 0 && bit_counter < 8 ) begin
                    //sample comparator
                    sample_reg[7 - bit_counter] <= comp_in;
                    
                    //determine new charge direction based on sample
                    rc_cntl <= comp_in;
                    bit_counter <= bit_counter + 1;
                    charge_counter <= charge_time >> 1;
                    charge_time <= charge_time >> 1;
                    
                end
                if ( bit_counter == 8 ) begin
                    NEW_ADC_SAMPLE <= 1'b1;
                    //average sum is now valid
                    ADC_reg_out <= sample_reg;
                end
                
            end
            else begin
                //discharge cap for next sample
                if ( charge_counter > 0 ) begin
                    charge_counter <= charge_counter - 1;
                end
                
                if ( charge_counter == 0 ) begin
                    discharging_cap <= 1'b0;
                    charge_counter <= half_charge_time;
                    rc_cntl <= 1'b1;
                end
            end
        end
    end

endmodule
    
    
    
    