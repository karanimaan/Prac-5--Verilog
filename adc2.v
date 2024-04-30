module ADC (
    input wire req,      // Request signal from TSC
    input wire rst,      // Reset signal for ADC
    output reg rdy,      // Ready signal to indicate completion
    output reg [7:0] dat // Data output from the array
);

// Constant array of values (16 data values)
reg [7:0] adc_data [0:15];

initial begin
    // Read ADC values from CSV file
    $readmemh("adc_values.csv", adc_data);

    // Initialize other signals
    rdy = 0;
    dat = 0;
end

reg [7:0] idx = 0; // Index to access the array

always @(posedge req or posedge rst) begin
    if (rst) begin
        // Reset the device
        rdy <= 0;
        dat <= 8'b00000000; // Reset data output
        idx <= 0; // Reset array index
    end else if (req) begin
        // Read data from the sample array using modular arithmetic
        dat <= adc_data[idx % 16]; // Wrap around if idx exceeds 15
        idx <= idx + 1;

        // Raise RDY line
        rdy <= 1;
    end else begin
        // Lower RDY line if not processing
        rdy <= 0;
    end
end

endmodule
