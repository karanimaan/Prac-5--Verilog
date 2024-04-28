`include "tscache.v"
`include "adc.v"
`timescale 1ns / 1ps

module TriggerSurroundCache_tb;

    // Inputs
    reg reset;       // reset when high
    reg start;       // start pulse
    reg clk;         // clock for TSC
    reg [7:0] adc_data;  // data from ADC
    reg req;         // request line to ADC
    wire rdy;
    wire [7:0] dat;

    // Outputs
    wire trd;         // trigger detected
    wire cd;          // completed data transfer
    wire [31:0] trigtm;  // when trigger
    wire sd;          // serial data out
    
  	ADC	adc_inst(
    	.req(req),
        .rst(rst),
        .rdy(rdy),
        .dat(dat)
    );
  
    // Instantiate the TSC module
    TriggerSurroundCache tsc (
        .reset(reset),
        .start(start),
        .clk(clk),
        .adc_data(adc_data),
        .req(req),
        .trd(trd),
        .cd(cd),
        .trigtm(trigtm),
        .sd(sd)
    );

    // Clock generation
    always #5 clk = ~clk;
    
    // Reset assertion
    initial begin
        reset = 1;
        start = 0;
        clk = 0;
        adc_data = dat;
        req = 0;
        #10 reset = 0;
//     end
    
//     // Test vectors
//     initial begin
        // Test case 1: Trigger condition met
        #20 start = 1;
        #10;
        adc_data = 8'hD7; // Above threshold
        req = 1;
        #10;
        adc_data = 8'h00; // Below threshold
        req = 0;
        #10;
        start = 0;
        
        // Test case 2: Data transfer complete
        #20 start = 1;
        #10;
        adc_data = 8'hD7; // Above threshold
        req = 1;
        #10;
        adc_data = 8'h00; // Below threshold
        req = 0;
        #10;
        start = 0;
       	$dumpfile("dump.vcd");
  		$dumpvars;
        #500 $finish; // Wait for data transfer to complete
        
     
        // Add more test cases as needed
    end

endmodule
