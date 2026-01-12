`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/01/2025 01:15:05 AM
// Design Name: 
// Module Name: processing_core
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//              
// 
//////////////////////////////////////////////////////////////////////////////////

module processing_core 
#(parameter WIDTH=10, DEPTH=1024)
(
    input  logic clk,
    input  logic bram_sel, cmd_ready, out_mode,
    input  logic cmd,
    input  logic [DEPTH-1:0][WIDTH-1:0] A, B,
    output logic [DEPTH-1:0][WIDTH-1:0] result_vec,                 // vector:  10 bits
    output logic [$clog2(DEPTH) + 10 + WIDTH-1:0] result_scalar,    // escalar: 30 bits
    output logic data_ready,    // ILA 
    //output logic ap_start,      // ILA
    output logic res_vld
);

// Maquina de estado
logic ap_ready, ap_done;
logic ap_start;

processing_core_fsm proc_core_fsm (
	.clk(clk),
	.cmd_ready(cmd_ready), 
	.out_mode(out_mode), 
	.ap_ready(ap_ready),
	.data_ready(data_ready), 
	.ap_start(ap_start),
	.ap_done(ap_done)
);

// Operaciones
logic [DEPTH-1:0][WIDTH-1:0] out_read;
logic [$clog2(DEPTH) + 10 + WIDTH-1:0] out_euc, out_dot;

// Demux para señales de control
logic ap_start_euc, ap_start_dot;
logic ap_ready_euc, ap_ready_dot;
logic ap_done_euc, ap_done_dot;
logic res_vld_euc, res_vld_dot;

always_comb begin
    if (cmd) begin
        ap_start_euc = 'b0;
        ap_start_dot = ap_start;
        ap_ready = ap_ready_dot;
        ap_done = ap_done_dot;
    end else begin
        ap_start_euc = ap_start;
        ap_start_dot = 'b0;
        ap_ready = ap_ready_euc;
        ap_done = ap_done_euc;
    end
end

read_vec_p #(.WIDTH(WIDTH), .DEPTH(DEPTH)) ReadVec (
    .in_A(A),
    .in_B(B),
    .sel(bram_sel),
    .out(out_read)
);

eucDist_0 EucDist (
    .ap_clk(clk),
    .ap_rst('b0),
    .ap_start(ap_start_euc),
    .ap_done(ap_done_euc),
    .ap_idle(),
    .ap_ready(ap_ready_euc),
    .res(out_euc),
    .res_ap_vld(res_vld_euc),
    // Conexiones automáticas
    `include "connect_ports.vh"
  );

dot_product_0 DotProd (
    .ap_clk(clk),
    .ap_rst('b0),
    .ap_start(ap_start_dot),
    .ap_done(ap_done_dot),
    .ap_idle(),
    .ap_ready(ap_ready_dot),
    .res(out_dot),
    .res_ap_vld(res_vld_dot),
    // Conexiones automáticas
    `include "connect_ports.vh"
  );
 
assign res_vld = res_vld_dot | res_vld_euc;

// Mux de salida
always_comb begin
    for (int i = 0; i < DEPTH; i++)
        result_vec[i] = out_read[i];
end

always_comb begin
    if (cmd)
        result_scalar = out_dot;
    else
        result_scalar = { {(30-16){1'b0}}, out_euc };
end


endmodule
