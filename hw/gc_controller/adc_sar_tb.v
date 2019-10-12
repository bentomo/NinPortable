    `timescale 1 ns / 1 ns

    module adc_sar_tb;

    /* Test case scenario */
    reg reset = 0;
    initial begin
     $dumpfile("adc_simout.vcd");
     $dumpvars;//(clk, reset, analog_value, capacitor_value, rc_cntl, digital_value);

     # 100 reset = 1; //at 100ns come out of reset
        
     # 100000 analog_value = 'd127; // analog_value = 'd127; //at 100us do half
     
     # 200000 analog_value = 'd200; //at 200us do 3/4
     
     # 300000 analog_value = 'd50; //at 300us do 1/4
     
     # 400000 analog_value = 'd255; //at 400us do 4/4
     
     # 500000 analog_value = 'd0; //at 500us do 0/4
     
     # 600000 analog_value = 'd225; //at 600us do 7/8
     
     # 700000 analog_value = 'd25; //at 700us do 1/8
     
     # 1000000 $finish; //1 ms
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

    //digital representations of external components
    parameter analog_width = 8; //this is adjusted based on the desired time constant 
    /* FIXME */ //adjust analog initial value
    reg [analog_width-1:0] analog_value = 0;
    reg [analog_width-1:0] capacitor_value = 0;
    //combinational logic to simulate comparitor
    wire comparator_out; //comparator result that is sent to adc_sar logic, defined with primitives on synthesizable level
    assign comparator_out = (analog_value > capacitor_value); //when value of + is greater than -, comparator_out = 1 else 0

        
    //outputs from adc_sar logic
    wire [7:0] digital_value;
    wire rc_cntl;

    //simulate capacitor charging
    //the simplest timing adjustment for the testbench is to adjust the width of the capacitor registers
    always @( posedge clk ) begin
        if ( rc_cntl == 1'b1 ) begin
            //this should never reach all 1's
            capacitor_value <= capacitor_value + 1;
        end
        else begin
            if ( capacitor_value == 0 ) begin
                capacitor_value <= 0;
            end
            else begin
                capacitor_value <= capacitor_value - 1;
            end
        end

    end


    adc_sar adc0 (
        .RESET( reset ),
        .comp_in ( comparator_out ),
        .CLK         ( clk ),
        .RC_CNTL     ( rc_cntl ),
        .DIGITAL_OUT ( digital_value )
    );

    /*FIXME*/ //uncomment this block for synthesizing on ICE40HX8K devboard to define comparator inputs
    //Differential input for analog_in, this module is from the lattice icecube technology library
    // defparam differential_input_analog_in.PIN_TYPE = 6'b000001 ; // {NO_OUTPUT, PIN_INPUT}
    // defparam differential_input_analog_in.IO_STANDARD = "SB_LVDS_INPUT" ;
    // SB_IO differential_input_joy_stick_X (
        // .PACKAGE_PIN(joy_stick_X),
        // .INPUT_CLK (clk),
        // .D_IN_0 (comparator_out)
    // );

    //for outputting to console
    // initial
     // $monitor("At time %t, Digital = %h (%0d)",
              // $time, digital_value, digital_value);
    endmodule // test