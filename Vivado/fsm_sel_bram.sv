`timescale 1ns / 1ps

module fsm_sel_bram(
    input logic clk, reset, rx_ready, flag_write, flag_end_write,
    input logic [7:0] rx_data,
    output logic sel_bram, reset_bram, flag_bram, busy_sel_bram
    );
    
    
    enum logic [2:0] {IDLE, READ_BYTE, BRAM_A, BRAM_B, HOLD_A, HOLD_B} state, next_state;
    
    always_ff @(posedge clk) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end
    
    always_comb begin
        next_state = IDLE;
        sel_bram   = 1'b0;
        reset_bram = 1'b0;
        flag_bram  = 1'b0;
        busy_sel_bram = 1'b0;

        case (state)
            IDLE: begin
                if (flag_write && rx_ready)
                    next_state = READ_BYTE;
            end
            
            READ_BYTE: begin
                busy_sel_bram = 1'b1;
                if (rx_data == 8'h00)
                    next_state = BRAM_A;
                else if (rx_data == 8'h11)
                    next_state = BRAM_B;
            end

            BRAM_A: begin
                sel_bram   = 1'b0;
                reset_bram = 1'b1;
                flag_bram  = 1'b1;
                busy_sel_bram = 1'b1;
                next_state = HOLD_A;
            end

            BRAM_B: begin
                sel_bram   = 1'b1;
                reset_bram = 1'b1;
                flag_bram  = 1'b1;
                busy_sel_bram = 1'b1;
                next_state = HOLD_B;
            end
            
            HOLD_A: begin
                sel_bram   = 1'b0;
                reset_bram = 1'b1;
                flag_bram  = 1'b1;
                busy_sel_bram = 1'b1;
                if (flag_end_write)
                    next_state = IDLE;
                else 
                    next_state = HOLD_A;
            end
            
            HOLD_B: begin
                sel_bram   = 1'b1;
                reset_bram = 1'b1;
                flag_bram  = 1'b1;
                busy_sel_bram = 1'b1;
                if (flag_end_write)
                    next_state = IDLE;
                else 
                    next_state = HOLD_B;
            end                
        endcase
    end   
endmodule
