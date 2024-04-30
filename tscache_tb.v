`include "tscache.v"
`include "adc2.v"
//`timescale 1ns / 1ps

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
    .trigtm(trigtm),
    .sd(sd)
);

ADC adc_inst (
    .req(req),
    .rst(reset),
  	.rdy(rdy),
    .dat(adc_data)
);

// Clock generation
always #CLK_PERIOD clk = ~clk;

// Initialize signals
initial begin
  	integer i;
  	clk = 0;
  	sbf = 0;
  	#10 start = 1;
  	// read and display 10 values from ADC to see it is working
  	$display("RDY\t	ADC_Data\t	TSC State");
  	for (i=0; i<15; i++)	begin
        // Send REQ pulse to ADC to read next value
            req = 1;
            #10; // Pulse width of 5 ns
            req = 0;
            #10
            if (adc_data >= tsc_inst.TRIGVL) begin 
              tsc_inst.current_state = tsc_inst.TRIGGERED;
            end
      // adc_data = dat;
      // display the value
      $display("%b\t\t %d\t\t\t %d",rdy,adc_data,state);               
    end    
  	#5
    reset = 1;
  	#5
  	#5
  	reset = 0;
    start = 0;
  	#5
    req = 0;
  	#5
  	req = 1;
  	#10
  	sbf = 1;
    #100 reset = 0; // Release reset after 100 ns

    // Apply test vectors
    #10 start = 1; // Start TSC operation
    #100 reset = 1;
	#20;
	$finish;
    // Continue applying test vectors...
end
  
initial begin
    $dumpfile("dump.vcd");
  	$dumpvars;
end

// Monitor ADC output
// always @(posedge clk) begin
//     $display("ADC Data: %h", adc_data);
// end
  
always @(posedge clk) begin
    state <= tsc_inst.current_state;
end

endmodule
