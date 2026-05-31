// ----------------------------------------------------------------------------
// cd4013 — dual D-type flip-flop
//
// Original chip/function : CD4013 dual D flip-flop with async SET and RESET,
//                          positive-edge clocked, complementary Q / Qn outputs.
// FPGA modeling approach : two flip-flops clocked by the FPGA clock. Each chip
//                          CLOCK pin is edge-detected (rising) against the FPGA
//                          clock to produce a capture enable — no gated clocks.
//                          SET and RESET are sampled synchronously.
// Differences from the IC: the real SET/RESET are asynchronous, level-active
//                          (high) inputs; here they take effect on the FPGA
//                          clock edge (deterministic). The real chip's CLOCK is
//                          an arbitrary signal; here it is treated as an
//                          edge-detected enable. When SET and RESET are both
//                          high, both Q and Qn go high (matching the datasheet).
// Parameters             : none
// Ports                  : clk, reset_n (FPGA clock + sync reset); per FF:
//                          d, clk_in (chip CLOCK), set, reset (active high),
//                          q, q_n
// Reset behavior         : reset_n low forces q=0, q_n=1 on both FFs
// Synthesis notes        : single clock domain; edge detector reuses
//                          rtl/common/edge_detector.
// Verification status    : self-checking testbench tb_cd4013.
//
// Written from public behavioral descriptions. No copyrighted content.
// ----------------------------------------------------------------------------
module cd4013 (
    input  logic clk,
    input  logic reset_n,
    // Flip-flop 1
    input  logic d1,
    input  logic clk1,        // chip CLOCK pin (rising-edge triggered)
    input  logic set1,        // active-high asynchronous SET (modeled sync)
    input  logic reset1,      // active-high asynchronous RESET (modeled sync)
    output logic q1,
    output logic q1_n,
    // Flip-flop 2
    input  logic d2,
    input  logic clk2,
    input  logic set2,
    input  logic reset2,
    output logic q2,
    output logic q2_n
);

    logic clk1_rise, clk2_rise;

    edge_detector u_ed1 (
        .clk(clk), .reset_n(reset_n), .signal_in(clk1),
        .rising_pulse(clk1_rise), .falling_pulse(), .edge_pulse()
    );
    edge_detector u_ed2 (
        .clk(clk), .reset_n(reset_n), .signal_in(clk2),
        .rising_pulse(clk2_rise), .falling_pulse(), .edge_pulse()
    );

    always_ff @(posedge clk) begin
        if (!reset_n) begin
            q1 <= 1'b0; q1_n <= 1'b1;
        end else begin
            if (set1 && reset1) begin q1 <= 1'b1; q1_n <= 1'b1; end
            else if (set1)      begin q1 <= 1'b1; q1_n <= 1'b0; end
            else if (reset1)    begin q1 <= 1'b0; q1_n <= 1'b1; end
            else if (clk1_rise) begin q1 <= d1;   q1_n <= ~d1;  end
        end
    end

    always_ff @(posedge clk) begin
        if (!reset_n) begin
            q2 <= 1'b0; q2_n <= 1'b1;
        end else begin
            if (set2 && reset2) begin q2 <= 1'b1; q2_n <= 1'b1; end
            else if (set2)      begin q2 <= 1'b1; q2_n <= 1'b0; end
            else if (reset2)    begin q2 <= 1'b0; q2_n <= 1'b1; end
            else if (clk2_rise) begin q2 <= d2;   q2_n <= ~d2;  end
        end
    end

endmodule : cd4013
