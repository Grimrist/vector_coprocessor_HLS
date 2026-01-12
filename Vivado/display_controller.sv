`timescale 1ns / 1ps

module display_controller #(parameter SOURCE_FREQ = 100000000, TARGET_FREQ = 400) (
    input  logic clk, exp_flag,
    input  logic [6:0] seg0, seg1, seg2, seg3, seg4, seg5, seg6, seg7,
    output logic [6:0] segments,
    output logic [7:0] anodes,
    output logic DP
);

    logic anode_pulse;
    logic [2:0] tdm_count;

    pulse_generator_mod #(.SOURCE_FREQ(SOURCE_FREQ), .TARGET_FREQ(TARGET_FREQ)) disp_pulse_gen (
        .clk_in(clk),
        .pulse_out(anode_pulse)
    );


    counter #(.N(3)) threebit_counter (
    .clk(clk),
    .enable(anode_pulse),
    .count(tdm_count)
    );

    // Multiplexor para elegir display y ánodo activo
    always_comb begin
        DP = 1'b1;
        case (tdm_count)
            3'd0: begin
                segments = seg0;
                anodes   = 8'b1111_1110;
            end
            3'd1: begin
                segments = seg1;
                anodes   = 8'b1111_1101;
            end
            3'd2: begin
                segments = seg2;
                anodes   = 8'b1111_1011;
            end
            3'd3: begin
                segments = seg3;
                anodes   = 8'b1111_0111;
            end
            3'd4: begin
                segments = seg4;
                anodes   = 8'b1110_1111;
            end
            3'd5: begin
                segments = seg5;
                anodes   = 8'b1101_1111;
            end
            3'd6: begin
                segments = seg6;
                anodes   = 8'b1011_1111;
            end
            3'd7: begin
                segments = seg7;
                anodes   = 8'b0111_1111;
                if (exp_flag)
                    DP = 1'b0;
            end
        endcase
    end

endmodule
