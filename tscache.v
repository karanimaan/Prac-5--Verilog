`timescale 1ns / 1ps

module TriggerSurroundCache (
    input wire reset,       // reset when high
    input wire start,       // start pulse
    input wire clk,         // clock for TSC
    input wire [7:0] adc_data,  // data from ADC
    input wire req,         // request line to ADC
    output reg trd,         // trigger detected
    output reg cd,          // completed data transfer
    output reg [31:0] trigtm,  // when trigger
    output reg sd           // serial data out
);

// Internal state signals
reg [3:0] current_state, next_state;

// Internal signals
reg [31:0] timer;
reg [31:0] ring_buffer [0:31];
reg [4:0] ring_head, ring_tail;
reg [7:0] trigger_threshold;
reg [31:0] buffer_data;

// Parameter
localparam 		 TRIGVL	 	   = 8'hD5; // example threshold value
localparam [3:0] IDLE		   = 4'b0000;
localparam [3:0] RUNNING       = 4'b0001;
localparam [3:0] TRIGGERED     = 4'b0010;
localparam [3:0] BUFFER_SEND   = 4'b0011;
  
// State register
always @(posedge clk or posedge reset) begin
    if (reset) begin
        current_state <= IDLE; // IDLE state
        trd <= 1'b0;
        cd <= 1'b0;
        timer <= 32'b0;
        ring_head <= 5'b0;
        ring_tail <= 5'b0;
        trigger_threshold <= TRIGVL;
    end else begin
        current_state <= next_state;
    end
end

// Output assignments
always @* begin
    trd = (current_state == TRIGGERED); // TRIGGERED state
    trigtm = (current_state == TRIGGERED) ? timer : 32'b0; // TRIGGERED state
    sd = (current_state == BUFFER_SEND); // BUFFER_SEND state
end

// State transition and logic
always @* begin
    case (current_state)
        IDLE: begin // IDLE state
            if (start) begin
                next_state = RUNNING; // RUNNING state
            end else if (req && (adc_data >= trigger_threshold)) begin
                next_state = TRIGGERED; // TRIGGERED state
            end else begin
                next_state = IDLE; // IDLE state
            end
        end
        RUNNING: begin // RUNNING state
            if (req && (adc_data >= trigger_threshold)) begin
                next_state = TRIGGERED; // TRIGGERED state
            end else begin
                next_state = RUNNING; // RUNNING state
            end
        end
        TRIGGERED: begin // TRIGGERED state
            if (ring_tail < 31) begin
                ring_buffer[ring_tail] <= adc_data;
                ring_tail <= ring_tail + 1;
            end
            if (ring_tail == 31) begin
                next_state = BUFFER_SEND; // BUFFER_SEND state
            end else begin
                next_state = TRIGGERED; // TRIGGERED state
            end
        end
        BUFFER_SEND: begin // BUFFER_SEND state
            if (ring_head < 31) begin
                buffer_data <= ring_buffer[ring_head];
                ring_head <= ring_head + 1;
            end
            if (ring_head == 31) begin
                cd <= 1'b1;
            end
            if (cd) begin
                next_state = IDLE; // IDLE state
            end else begin
                next_state = BUFFER_SEND; // BUFFER_SEND state
            end
        end
        default: next_state = IDLE; // IDLE state
    endcase
end

endmodule
