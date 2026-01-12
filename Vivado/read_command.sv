`timescale 1ns / 1ps

module fsm_read_command(
    input  logic clk, reset, rx_ready, enable,     
    input  logic [7:0] rx_data,
    output logic flag_write, flag_command             
    
);

    enum logic [2:0] {IDLE, READ_BYTE, WRITE_MODE, COMMAND_MODE, HOLD_WRITE, HOLD_COMMAND} state, next_state;

    always_ff @(posedge clk) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    always_comb begin
        next_state   = IDLE;
        flag_write   = 1'b0;
        flag_command = 1'b0;

        case (state)
            IDLE: begin
                if (rx_ready && enable)
                    next_state = READ_BYTE;
            end
            
            READ_BYTE: begin
                if (rx_data == 8'h00)
                    next_state = WRITE_MODE;
                else
                    next_state = COMMAND_MODE;
            end

            WRITE_MODE: begin
                next_state = HOLD_WRITE;
                flag_write = 1'b1;
            end

            COMMAND_MODE: begin
                next_state = HOLD_COMMAND;
                flag_command = 1'b1;
            end
            
            HOLD_WRITE: begin
                flag_write = 1'b1;
                if (rx_ready)
                    next_state = IDLE;
                else 
                    next_state = HOLD_WRITE;   
            end      
               
            HOLD_COMMAND: begin
                flag_command = 1'b1;
//                if (rx_ready)
//                    next_state = IDLE;  
//                else 
                next_state = IDLE;
            end  
        endcase
    end
endmodule
