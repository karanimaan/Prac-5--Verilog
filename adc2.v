// TSC simulation module

// set simulation time:
`timescale 1ns / 1ps

module ADC2  (
    input wire req,      // Request signal from TSC
    input wire rst,      // Reset signal for ADC
    output reg rdy,      // Ready signal to indicate completion
    output reg [7:0] dat // Data output from the array
);

// Declare file I/O variables
file csv_file;
reg [7:0] adc_data [0:15]; // Assuming 16 ADC values
integer csv_value;
integer adc_index;

// Initialize variables
initial begin
    rdy = 0;
    adc_index = 0;

    // Open CSV file for reading
    csv_file = $fopen("adc_data.csv", "r");
    if (csv_file == 0) begin
        $display("Error: Could not open file");
        $finish;
    end

    // Read ADC data from CSV file
    while (!($feof(csv_file)) && adc_index < 16) begin
        $fscanf(csv_file, "%d,\n", csv_value); // Assuming CSV values are comma-separated
        adc_data[adc_index] = csv_value;
        adc_index = adc_index + 1;
    end

    // Close CSV file
    $fclose(csv_file);
end

// Read ADC data
always @(posedge req or posedge rst) begin
    if (rst) begin
        // Reset the device
        rdy <= 0;
        dat <= 8'b00000000; // Reset data output
        adc_index <= 0;     // Reset array index
    end else if (req && adc_index < 16) begin
        // Read data from the array
        dat <= adc_data[adc_index];
        adc_index <= adc_index + 1;
        rdy <= 1; // Raise RDY line
    end else begin
        rdy <= 0; // Lower RDY line if not processing
    end
end

endmodule
