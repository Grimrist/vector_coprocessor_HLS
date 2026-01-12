module fsm_concatenation (
    input  logic        clk, reset,
    input  logic        rx_ready,
    input  logic [7:0]  rx_data,
    input  logic        flag_bram,   // se levanta cuando ya se seleccionó BRAM
    output logic [9:0]  data_out,
    output logic        flag_data_ready,
    output logic        busy_concat,
    output logic        flag_end_write
);

    enum logic [2:0] {IDLE, BYTE1, HOLD ,BYTE2, CHECK_BYTE, DONE, WAIT_NEXT_BYTE,END_WRITE} state, next_state;

    logic [7:0] low_byte, high_byte;

    // Secuencial
    always_ff @(posedge clk) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Combinacional
    always_comb begin
        next_state = IDLE;
        flag_data_ready = 1'b0;
        busy_concat = 1'b0;
        flag_end_write = 1'b0;
        
        case (state)
            IDLE: begin
                if (flag_bram && rx_ready)
                    next_state = BYTE1;
            end

            BYTE1: begin
                busy_concat = 1'b1;
                next_state = HOLD;
            end
            
            HOLD: begin
                busy_concat = 1'b1;
                if (rx_ready)
                    next_state = BYTE2;
                else
                    next_state = HOLD;
            end
                

            BYTE2: begin
                busy_concat = 1'b1;
                next_state = CHECK_BYTE;
            end
            
            CHECK_BYTE: begin
                busy_concat = 1'b1;
                if (high_byte == 8'hFF)
                    next_state = END_WRITE;
                else
                    next_state = DONE;
            end
            
            END_WRITE: begin
                busy_concat = 1'b1;  
                flag_end_write = 1'b1;
            end

            DONE: begin
                busy_concat = 1'b1;
                flag_data_ready = 1'b1;
                next_state = WAIT_NEXT_BYTE;
            end
            
            WAIT_NEXT_BYTE: begin
                next_state = WAIT_NEXT_BYTE;
                busy_concat = 1'b1;
                flag_data_ready = 1'b0;
                if (rx_ready)
                    next_state = BYTE1;
            end
        endcase
    end

    // Captura de bytes
    always_ff @(posedge clk) begin
        if (state == BYTE1)
            low_byte <= rx_data;
        if (state == BYTE2)
            high_byte <= rx_data;
    end

    // Salida final
    assign data_out = {high_byte[1:0], low_byte[7:0]};

endmodule
