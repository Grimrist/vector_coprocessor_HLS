`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/05/2025 12:45:55 AM
// Design Name: 
// Module Name: PISO_RAM
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


module PISO_RAM #(parameter WIDTH=10, DEPTH=1024) (
    input logic clk,
    input logic [DEPTH-1:0][WIDTH-1:0] d,
    input logic [$clog2(DEPTH)-1:0] r_addr,
    output logic [WIDTH-1:0] q
);

logic [DEPTH-1:0][WIDTH-1:0] q_reg;

always_ff @(posedge clk) begin
    q_reg <= d;
end

assign q = q_reg[r_addr];

endmodule
