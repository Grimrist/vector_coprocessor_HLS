`timescale 1ns / 1ps

module top_uart_rx
#(
    parameter CLK_FREQUENCY = 100_000_000,
    parameter BAUD_RATE = 115200
)(
    input clk,
    input reset,
    input rx,
    output [7:0] rx_data,
    output reg rx_ready
);

    wire baud8_tick;
    wire rx_ready_pre;

    reg rx_ready_sync;

    // Generador de tick con oversampling 8x para RX
    uart_baud_tick_gen #(
        .CLK_FREQUENCY(CLK_FREQUENCY),
        .BAUD_RATE(BAUD_RATE),
        .OVERSAMPLING(8)
    ) baud8_tick_blk (
        .clk(clk),
        .enable(1'b1),
        .tick(baud8_tick)
    );

    // Bloque RX
    uart_rx uart_rx_blk (
        .clk(clk),
        .reset(reset),
        .baud8_tick(baud8_tick),
        .rx(rx),
        .rx_data(rx_data),
        .rx_ready(rx_ready_pre)
    );

    // Pulso de rx_ready
    always @(posedge clk) begin
        rx_ready_sync <= rx_ready_pre;
        rx_ready <= ~rx_ready_sync & rx_ready_pre;
    end

endmodule
