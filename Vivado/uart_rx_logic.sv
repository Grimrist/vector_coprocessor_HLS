`timescale 1ns / 1ps

module uart_rx_logic #(
    parameter CLK_FREQUENCY = 100_000_000,
    parameter BAUD_RATE = 115200,
    parameter MEMORY_DEPTH = 1024
)(
    input logic clk, rst, 
    input logic rx,
    output logic wea_a,
    output logic [9:0] d_in,
    output logic wea_b,
    output logic flag_command, flag_write,
    output logic [7:0] rx_data
);

logic rx_ready;

// Instancia del receptor UART
top_uart_rx #(
    .CLK_FREQUENCY(CLK_FREQUENCY),
    .BAUD_RATE(BAUD_RATE)
) uart_rx_inst (
    .clk(clk),
    .reset(rst),  // reset activo en alto dentro del módulo
    .rx(rx),
    .rx_data(rx_data),
    .rx_ready(rx_ready)
);

//---------------------------------------------------------
// Señales internas
//---------------------------------------------------------
logic busy_sel_bram;
logic busy_concat;
logic enable_fsm_read;
logic flag_end_write;
logic [9:0] data_out;

// Señales comunes de control (FSM_RX_ctrl)
logic write_enable_common;

//---------------------------------------------------------
// Lógica de control entre FSMs
//---------------------------------------------------------
assign enable_fsm_read = ~(busy_sel_bram | busy_concat);

//---------------------------------------------------------
// FSM 1: Lectura de comando principal
//---------------------------------------------------------
fsm_read_command fsm_read_command_inst (
    .clk(clk),
    .reset(rst),
    .rx_ready(rx_ready),
    .enable(enable_fsm_read),
    .rx_data(rx_data),
    .flag_write(flag_write),
    .flag_command(flag_command)
);

//---------------------------------------------------------
// FSM 2: Selección de bloque BRAM según segundo byte
//---------------------------------------------------------
fsm_sel_bram fsm_sel_bram_inst (
    .clk(clk),
    .reset(rst),
    .rx_ready(rx_ready),
    .flag_write(flag_write),
    .rx_data(rx_data),
    .sel_bram(sel_bram),
    .reset_bram(reset_bram),
    .flag_bram(flag_bram),
    .busy_sel_bram(busy_sel_bram),
    .flag_end_write(flag_end_write)
);

//---------------------------------------------------------
// FSM 3: Concatenación de bytes recibidos (dato de 10 bits)
//---------------------------------------------------------
fsm_concatenation fsm_concatenation_inst (
    .clk(clk),
    .reset(rst),
    .rx_ready(rx_ready),
    .rx_data(rx_data),
    .flag_bram(flag_bram),
    .data_out(data_out),
    .flag_data_ready(flag_data_ready),
    .busy_concat(busy_concat),
    .flag_end_write(flag_end_write)
);

//---------------------------------------------------------
// FSM 4: Control de escritura en BRAM
//---------------------------------------------------------
FSM_RX_ctrl FSM_RX_ctrl_inst (
    .clk(clk),
    .rx_ready(flag_data_ready),  // viene de fsm_concatenation
    .rx_data(data_out),          // viene de fsm_concatenation
    .write_enable(write_enable_common),
    .write_data(d_in)
);

//---------------------------------------------------------
// Multiplexores de selección de banco BRAM
//---------------------------------------------------------
// Selección de señales de control
always_comb begin
    // Banco A (sel_bram = 0)
    wea_a  = (sel_bram == 1'b0) ? write_enable_common : 1'b0;
    // Banco B (sel_bram = 1)
    wea_b  = (sel_bram == 1'b1) ? write_enable_common : 1'b0;
end

endmodule
