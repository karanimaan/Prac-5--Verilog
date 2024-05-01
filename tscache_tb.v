`include "tscache.v"
// `include "adc.v"
`timescale 1ns / 1ps

module tb;

// Define parameters
parameter CLK_PERIOD = 10; // Clock period in ns

// Declare signals
reg clk;
reg reset;
reg start;
reg req;
wire [7:0] adc_data;
wire trd;
wire cd;
wire [31:0] trigtm;
wire sd;
wire rdy;
wire [7:0] dat;
reg sbf;
reg [3:0] state; // Added signal to monitor TSC state

// Instantiate the TSC and ADC modules
TriggerSurroundCache tsc_inst (
    .reset(reset),
    .start(start),
    .clk(clk),
  	.adc_data(adc_data),
    .req(req),
    .trd(trd),
    .cd(cd),
  	.sbf(sbf),
  	.rdy(rdy),
    .trigtm(trigtm),
    .sd(sd),
    .current_state(state)
);


// Clock generation
always #CLK_PERIOD clk = ~clk;

// Initialize signals
initial begin
  	integer i;
  	clk = 0;
  	sbf = 0;
  	req = 0;


  	$display("reset\t start\t req\t data\t trd\t sbf\t cd\t state");
  	$monitor("%b\t %b\t %b\t %d\t %b\t %b\t %b\t %d", reset, start, req, adc_data, trd, sbf, cd, state);

    start = 0;
    reset = 0;

  	//#20 start = 1; #20 start = 0;

    //#5 reset = 1; #5 reset = 0;

    // Toggling req (request line)
    for (i=0; i<15; i++) begin
        if (state == 0) begin
            #20 start = 1; #20 start = 0;   // This doesn't show first in $monitor, for some reason
        end
        #50 req = 1;
        #50 req = 0;
    end

end
  



endmodule
