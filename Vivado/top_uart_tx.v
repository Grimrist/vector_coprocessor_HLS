`timescale 1ns / 1ps

module top_uart_tx
#(
    parameter CLK_FREQUENCY = 100_000_000,
    parameter BAUD_RATE = 115200
)(
    input clk,
    input reset,
    output tx,
    input tx_start,
    input [7:0] tx_data,
    output tx_busy
);

    wire baud_tick;

    // Generador de tick sin oversampling (1x) para TX
    uart_baud_tick_gen #(
        .CLK_FREQUENCY(CLK_FREQUENCY),
        .BAUD_RATE(BAUD_RATE),
        .OVERSAMPLING(1)
    ) baud_tick_blk (
        .clk(clk),
        .enable(tx_busy),
        .tick(baud_tick)
    );

    // Bloque TX
    uart_tx uart_tx_blk (
        .clk(clk),
        .reset(reset),
        .baud_tick(baud_tick),
        .tx(tx),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx_busy(tx_busy)
    );

endmodule
