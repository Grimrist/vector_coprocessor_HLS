`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2025 10:13:08 PM
// Design Name: 
// Module Name: read_vec_p
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


module read_vec_p #(parameter WIDTH=10, DEPTH=1024) (
    input logic [DEPTH-1:0][WIDTH-1:0] in_A, in_B,
    input logic sel,
    output logic [DEPTH-1:0][WIDTH-1:0] out
);

always_comb begin
    for (int i = 0; i < DEPTH; i++)
        if (sel)
            out[i] = in_B[i];
        else
            out[i] = in_A[i];
end
endmodule
