`timescale 1ns / 1ps

module display_top #(parameter SOURCE_FREQ = 100000000, TARGET_FREQ = 400) (
    input  logic        clk,
    input  logic [29:0] result,
    input  logic        out_mode, data_ready, cmd_ready, disable_screen,   
    output logic [6:0]  segments,
    output logic [7:0]  anodes,
    output logic DP
);
  
    logic [6:0] seg0_bcd, seg1_bcd, seg2_bcd, seg3_bcd, seg4_bcd, seg5_bcd, seg6_bcd, seg7_bcd, seg8_bcd, seg9_bcd;
    logic [6:0] seg0, seg1, seg2, seg3, seg4, seg5, seg6, seg7, seg8, seg9;
    
    localparam e_seg = 7'b1001111;
    localparam eight_seg = 7'b1111111;
    localparam nine_seg = 7'b1111011;
    
    logic exp_flag;
    
    always_comb begin
        if (result >= 'd100_000_000)
            exp_flag = 1'b1;
        else
            exp_flag = 1'b0;
    end
    
    always_comb begin
        if (result >= 'd1_000_000_000)
            {seg7, seg6, seg5, seg4, seg3, seg2, seg1, seg0} = {seg9_bcd, seg8_bcd, seg7_bcd, seg6_bcd, seg5_bcd, seg4_bcd, e_seg, nine_seg};
        else if (result >= 'd100_000_000)
            {seg7, seg6, seg5, seg4, seg3, seg2, seg1, seg0} = {seg8_bcd, seg7_bcd, seg6_bcd, seg5_bcd, seg4_bcd, seg3_bcd, e_seg, eight_seg};
        else
            {seg7, seg6, seg5, seg4, seg3, seg2, seg1, seg0} = {seg7_bcd, seg6_bcd, seg5_bcd, seg4_bcd, seg3_bcd, seg2_bcd, seg1_bcd, seg0_bcd};
    end

    // Decoder
    result_decoder result_decoder (
        .clk(clk),
        .result(result),
        .seg0(seg0_bcd),
        .seg1(seg1_bcd),
        .seg2(seg2_bcd),
        .seg3(seg3_bcd),
        .seg4(seg4_bcd),
        .seg5(seg5_bcd),
        .seg6(seg6_bcd),
        .seg7(seg7_bcd),
        .seg8(seg8_bcd),
        .seg9(seg9_bcd)
    );

    // Controller
    logic [6:0] segments_int;
    logic [7:0] anodes_int;
    
    display_controller #(.SOURCE_FREQ(SOURCE_FREQ), .TARGET_FREQ(TARGET_FREQ)) display_controller (
        .clk(clk),
        .seg0(seg0),
        .seg1(seg1),
        .seg2(seg2),
        .seg3(seg3),
        .seg4(seg4),
        .seg5(seg5),
        .seg6(seg6),
        .seg7(seg7),
        .segments(segments_int),
        .anodes(anodes_int),
        .exp_flag(exp_flag),
        .DP(DP_int)
    );
    
    logic disp_on;
    
    always_ff @(posedge clk) begin
        if (data_ready && out_mode)
            disp_on = 1'b1;
        else if (cmd_ready || disable_screen)
            disp_on = 1'b0;
    end
    
    always_comb begin
        if (!disp_on) begin
            segments = 7'b000_0000;   // todos los LEDs apagados
            anodes   = 8'b1111_1111;  // todos desactivados
            DP = 1'b1;
        end else begin
            segments = segments_int;
            anodes   = anodes_int;
            DP = DP_int;
        end
    end

endmodule
