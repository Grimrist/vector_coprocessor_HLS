`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/09/2025 11:11:20 PM
// Design Name: 
// Module Name: command_block
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


module command_block (
    input logic clk,
    input logic [2:0] rx_data,
    input logic flag_command, flag_write,
    output logic cmd,
    output logic cmd_ready,
    output logic out_mode,
    output logic disable_screen,
    output logic bram_sel
);

always_ff @(posedge clk) begin
    cmd <= rx_data[0];
    out_mode <= rx_data[1];
    bram_sel <= rx_data[2];
end

always_ff @(posedge clk) begin
    if (flag_command)
        cmd_ready <= 'b1;
    else
        cmd_ready <= 'b0;
end

always_ff @(posedge clk) begin
    if (flag_write)
        disable_screen <= 1'b1;
    else if (flag_command)
        disable_screen <= 1'b0;
end


endmodule
