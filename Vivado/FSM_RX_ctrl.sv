`timescale 1ns / 1ps
module FSM_RX_ctrl (
    input  logic clk,
    input  logic rx_ready,     // Indica que llega un nuevo dato
    input  logic [9:0] rx_data,
    output logic write_enable, // Escritura a memoria
    output logic [9:0] write_data
);

    // ------------------------------------------------------------
    // Señales internas
    // ------------------------------------------------------------
    enum logic [1:0] {READ_BYTE, WRITE_BYTE} state, state_next;
    logic [9:0] rx_data_reg;

    // ------------------------------------------------------------
    // Registro del dato recibido (evita desfase con write_enable)
    // ------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (rx_ready)
            rx_data_reg <= rx_data;
    end

    assign write_data = rx_data_reg;

    // ------------------------------------------------------------
    // Máquina de estados
    // ------------------------------------------------------------
    always_ff @(posedge clk) begin
        state <= state_next;
    end
    

    always_comb begin
        // Valores por defecto
        state_next   = state;
        write_enable = 1'b0;

        case (state)
            READ_BYTE: begin
                if (rx_ready)
                    state_next = WRITE_BYTE;
            end

            WRITE_BYTE: begin
                write_enable = 1'b1;
                state_next   = READ_BYTE;
            end
            default:
                state_next = READ_BYTE;
        endcase
    end
    
endmodule
