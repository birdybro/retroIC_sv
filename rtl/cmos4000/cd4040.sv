// ----------------------------------------------------------------------------
// cd4040 — 12-stage binary ripple counter (FPGA-safe synchronous model)
//
// Original chip/function : CD4040 12-stage binary ripple counter. Counts on the
//                          high-to-low (falling) transition of the clock input;
//                          active-high asynchronous master reset; outputs Q1..Q12.
// FPGA modeling approach : a single synchronous binary counter clocked by the
//                          FPGA clock. The chip CLOCK pin is edge-detected
//                          (falling) to produce a count enable — no gated
//                          clocks, no ripple chain. q[0]=Q1 (fastest) ..
//                          q[11]=Q12.
// Differences from the IC: the real device ripples — each stage toggles after
//                          the previous stage with cumulative propagation delay,
//                          so stage outputs are momentarily skewed. Here all
//                          bits update together on the FPGA clock edge that
//                          follows a detected falling edge of clk_in. Functional
//                          count value matches; intermediate ripple glitches do
//                          not. Master reset is async on the real part; modeled
//                          synchronously here.
// Parameters             : STAGES — number of stages (default 12)
// Ports                  : clk, reset_n (FPGA clock + sync reset), clk_in
//                          (counted clock), master_reset (active-high clear),
//                          q[STAGES-1:0]
// Reset behavior         : reset_n low or master_reset high clears q to 0
// Synthesis notes        : single clock domain; reuses rtl/common/edge_detector.
// Verification status    : self-checking testbench tb_cd4040.
//
// Written from public behavioral descriptions. No copyrighted content.
// ----------------------------------------------------------------------------
module cd4040 #(
    parameter int STAGES = 12
) (
    input  logic              clk,
    input  logic              reset_n,
    input  logic              clk_in,        // counted clock (falling-edge)
    input  logic              master_reset,  // active-high clear
    output logic [STAGES-1:0] q
);

    logic clk_fall;

    edge_detector #(.DETECT_RISING(1'b0), .DETECT_FALLING(1'b1)) u_ed (
        .clk(clk), .reset_n(reset_n), .signal_in(clk_in),
        .rising_pulse(), .falling_pulse(clk_fall), .edge_pulse()
    );

    always_ff @(posedge clk) begin
        if (!reset_n)          q <= '0;
        else if (master_reset) q <= '0;
        else if (clk_fall)     q <= q + 1'b1;
    end

endmodule : cd4040
