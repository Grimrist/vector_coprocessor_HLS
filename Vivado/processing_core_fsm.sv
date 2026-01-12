`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/06/2025 05:02:20 PM
// Design Name: 
// Module Name: processing_core_fsm
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


module processing_core_fsm (
	input logic clk, cmd_ready, out_mode, ap_ready, ap_done,
	output logic data_ready, ap_start
);

//Declarations:------------------------------

//FSM states type:
enum logic [4:0] {IDLE, READ_EXEC, CUM_EXEC, CUM_SEND, CUM_WAIT} CurrentState, NextState;

//Statements:---------------------------------------
initial CurrentState = IDLE;
initial NextState = IDLE;

//FSM state register:
always_ff @(posedge clk)
    CurrentState <= NextState;

//FSM combinational logic:
always_comb begin
    ap_start = 1'b0;
    data_ready = 1'b0;
    case (CurrentState)
        IDLE: begin
            if (cmd_ready) begin
                if (!out_mode) NextState = READ_EXEC;
                else NextState = CUM_EXEC;
            end
            else NextState = IDLE;
        end
    
        READ_EXEC: begin
            data_ready = 1'b1;
            NextState = IDLE;
        end
        
        CUM_EXEC: begin
            ap_start = 1'b1;
            if (ap_ready) NextState = CUM_SEND;
            else NextState = CUM_EXEC;
        end
        
        CUM_SEND: begin
            data_ready = 1'b1;
            NextState = IDLE;
        end
        
        CUM_WAIT: begin
            ap_start = 1'b0;
            data_ready = 1'b0;
            if (ap_done) NextState = CUM_SEND;
            else NextState = CUM_WAIT;
        end
        
        default: begin
            NextState = IDLE;
        end
    endcase
end
////Optional output register (if required). Adds a FF at the output to prevent the propagation of glitches from comb. logic.
//always_ff @(posedge clk)
//    if (rst) begin //rst might be not needed here
//        new_outp1 <= ...;
//        new_outp2 <= ...; ...
//    end
//    else begin
//        new_outp1 <= outp1;
//        new_outp2 <= outp2; ...
//    end

endmodule
