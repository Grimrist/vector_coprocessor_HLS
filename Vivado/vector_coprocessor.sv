`timescale 1ns / 1ps

module vector_coprocessor 
#(parameter MEMORY_DEPTH = 1024, parameter MEMORY_WIDTH = 10) (
    input logic clk, rx,
    output logic tx,
    output logic [6:0] segments,
    output logic [7:0] anodes,
    output logic DP
);

// Clock used for design
logic clk_sys;

clk_wiz_0 clk_src (
    .clk_in1(clk),
    .reset('b0),
    .clka(clk_sys),
    .locked()
);

localparam CLKA_FREQ = 122_000_000;

// SIPO RAM instances
logic [MEMORY_WIDTH-1:0] d_in;

logic [MEMORY_DEPTH-1:0][MEMORY_WIDTH-1:0] doutb_a, doutb_b;
logic wea_a, wea_b;

SIPO_RAM #(.WIDTH(MEMORY_WIDTH), .DEPTH(MEMORY_DEPTH)) SIPO_Vector_A (
    .clk(clk_sys),
    .d(d_in),
    .q(doutb_a),
    .w_en(wea_a)
);

SIPO_RAM #(.WIDTH(MEMORY_WIDTH), .DEPTH(MEMORY_DEPTH)) SIPO_Vector_B (
    .clk(clk_sys),
    .d(d_in),
    .q(doutb_b),
    .w_en(wea_b)
);

// UART RX Logic
logic flag_command, flag_write;
logic [7:0] rx_data;

uart_rx_logic #(
    .CLK_FREQUENCY(CLKA_FREQ),
    .BAUD_RATE(115200),
    .MEMORY_DEPTH(MEMORY_DEPTH)
) UART_RX_Logic (
    .clk(clk_sys), 
    .rst('b0), 
    .rx,
    .wea_a, 
    .wea_b, 
    .d_in,
    .flag_command,
    .flag_write,
    .rx_data
);

// Command block
logic out_mode, disable_screen, cmd_ready, bram_sel;
logic cmd;

command_block Command_Block (
    .clk(clk_sys), 
    .rx_data(rx_data[3:1]),
    .flag_command, 
    .flag_write,
    .cmd,
    .cmd_ready,
    .out_mode,
    .disable_screen,
    .bram_sel
);

// Processing core
logic [MEMORY_DEPTH-1:0][MEMORY_WIDTH-1:0] result_vec;
logic [$clog2(MEMORY_DEPTH) + 10 + MEMORY_WIDTH-1:0] result_scalar, scalar_reg;
logic [7:0] tx_data;
logic res_vld;

logic data_ready;   // ILA
//logic ap_start;     // ILA

processing_core #(.DEPTH(MEMORY_DEPTH), .WIDTH(MEMORY_WIDTH)) Processing_Core (
    .clk(clk_sys),
    .cmd(cmd),
    .cmd_ready(cmd_ready),
    .out_mode(out_mode),
    .bram_sel(bram_sel),
    .A(doutb_a), 
    .B(doutb_b),
    .result_vec(result_vec),
    .result_scalar(result_scalar),
    .res_vld(res_vld),
    //.ap_start(ap_start),        // ILA
    .data_ready(data_ready)     // ILA  
);


//ila_0 ILA_Latencia (
//	.clk(clk_sys), // input wire clk
//	.probe0(ap_start), // input wire [0:0]  probe0  
//	.probe1(data_ready) // input wire [0:0]  probe1
//);


// PISO RAM for vector output
logic [MEMORY_WIDTH-1:0] vec_out;
logic [$clog2(MEMORY_DEPTH)-1:0] r_addr;

PISO_RAM #(.WIDTH(MEMORY_WIDTH), .DEPTH(MEMORY_DEPTH)) PISO_Vector_Res (
    .clk(clk_sys),
    .r_addr(r_addr),
    .d(result_vec),
    .q(vec_out)
);

// FF to hold scalar output
always_ff @(posedge clk_sys) begin
    if (res_vld)
        scalar_reg <= result_scalar;
    else
        scalar_reg <= scalar_reg;
end

logic tx_start, tx_busy;
logic [1:0] byte_sel;

tx_splitter #(.MAX_ADDR(MEMORY_DEPTH)) splitter (
    .clk(clk_sys),
    .data_ready(data_ready),
    .r_addr(r_addr),
    .max_pck('d3),
	.byte_sel(byte_sel), 
	.tx_busy(tx_busy),
	.out_mode(out_mode),
	.tx_start(tx_start)
);

logic [31:0] data_out;

always_comb begin
    if (out_mode)
        data_out = {2'b0, scalar_reg};
    else
        data_out = {22'b0, vec_out};
end

// Mux to pick which part of result to send
always_comb begin
    case (byte_sel)
        'd0: tx_data = data_out[8*0+:8];
        'd1: tx_data = data_out[8*1+:8];
        'd2: tx_data = data_out[8*2+:8];
        'd3: tx_data = data_out[8*3+:8];
    endcase
end

logic [6:0] segments_out;

display_top 
#(.SOURCE_FREQ(CLKA_FREQ), .TARGET_FREQ(400)) display_top (
    .clk(clk_sys),
    .result(scalar_reg),
    .segments(segments_out),
    .out_mode(out_mode),
    .cmd_ready(cmd_ready),
    .data_ready(data_ready),
    .disable_screen(disable_screen),
    .anodes(anodes),
    .DP(DP)
);

assign segments = ~segments_out;

top_uart_tx #(
    .CLK_FREQUENCY(CLKA_FREQ),
    .BAUD_RATE(115200) 
) UART_TX (
    .clk(clk_sys),
    .reset('b0),
    .tx(tx),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .tx_busy(tx_busy)
);

endmodule
