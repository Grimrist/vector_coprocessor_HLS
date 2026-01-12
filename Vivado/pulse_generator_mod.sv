`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/18/2025 09:38:20 PM
// Design Name: 
// Module Name: pulse_generator_mod
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pulse_generator_mod
#(parameter SOURCE_FREQ = 100000000, TARGET_FREQ = 50000000)
( input  logic clk_in,
  output logic pulse_out );
  
  localparam COUNTER_MAX = SOURCE_FREQ / TARGET_FREQ;
  localparam DELAY_WIDTH = $clog2(COUNTER_MAX);
  logic [DELAY_WIDTH-1:0] counter = 'd0;
  
  always_ff @(posedge clk_in) begin
    if (counter == COUNTER_MAX-1) begin
        counter <= 'd0;
        pulse_out <= 1'b1;
    end 
    else begin
        counter <= counter + 'd1;
        pulse_out <= 1'b0;
    end
  end
  
endmodule

