`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/08/2025 04:15:35 PM
// Design Name: 
// Module Name: tx_splitter
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


module tx_splitter #(parameter MAX_ADDR=1024) (
	input 	logic clk,
	input 	logic data_ready, tx_busy, out_mode, 
	input   logic [1:0] max_pck,
	output  logic [$clog2(MAX_ADDR)-1:0] r_addr,
	output 	logic tx_start, 
	output  logic [1:0] byte_sel
);

//FSM states type:
enum logic [4:0] {IDLE, SEND_BYTE, WAIT_BYTE, INCR_BYTE, INCR_ADDR} CurrentState, NextState;

//Declarations:------------------------------
logic incr_sel, reset_sel, incr_addr;
 
always_ff @(posedge clk) begin
    if (reset_sel)
        byte_sel <= 'b0;
    else if (incr_sel)
        byte_sel <= byte_sel + 1'b1;
end

always_ff @(posedge clk) begin  
    if (CurrentState == IDLE)
        r_addr <= 'b0;
    else if (incr_addr)
        r_addr <= r_addr + 1;
end



//Statements:--------------------------------

//FSM state register:
always_ff @(posedge clk)
    CurrentState <= NextState;

//FSM combinational logic:
always_comb begin
    incr_addr = 1'b0;
    incr_sel = 1'b0;
    tx_start = 1'b0;
    reset_sel = 1'b0;
    
    case (CurrentState)
        IDLE: begin
            reset_sel = 1'b1;
            if (data_ready) NextState = SEND_BYTE;
            else NextState = IDLE;
        end
    
        SEND_BYTE: begin
            tx_start = 1'b1;
            NextState = WAIT_BYTE;
        end
    
        WAIT_BYTE: begin
            if (!tx_busy) NextState = INCR_BYTE;
            else NextState = WAIT_BYTE;
        end
        
        INCR_BYTE: begin
            incr_sel = 1'b1;
            if (byte_sel >= max_pck) NextState = INCR_ADDR;
            else NextState = SEND_BYTE;
        end

        INCR_ADDR: begin
            incr_addr = 1'b1;
            reset_sel = 1'b1;
            if (out_mode) NextState = IDLE;
            else if (r_addr >= MAX_ADDR-1) NextState = IDLE;
            else NextState = SEND_BYTE;
        end
        
        default: begin
            NextState = IDLE;
        end
    endcase
end

endmodule
