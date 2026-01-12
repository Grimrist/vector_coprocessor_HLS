`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/03/2025 03:45:34 PM
// Design Name: 
// Module Name: sifo
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


module SIPO_RAM #(parameter WIDTH=10, DEPTH=64) (
    input logic clk,
    input logic [WIDTH-1:0] d,
    input logic w_en,
    output logic [DEPTH-1:0][WIDTH-1:0] q
);

logic [DEPTH-1:0][WIDTH-1:0] q_reg;

always_ff @(posedge clk) begin
    if (w_en)
//        for (int i = 1; i < DEPTH; i++) begin
//            q_rega[i] <= q_rega[i-1];
//        end
//        q_rega[0] = q;
        q_reg[DEPTH-1:0] <= {d, q_reg[DEPTH-1:1]};
end

assign q = q_reg;

endmodule
