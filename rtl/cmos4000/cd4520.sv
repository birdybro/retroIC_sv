// ----------------------------------------------------------------------------
// cd4520 — dual 4-bit synchronous binary up-counter
//
// Original chip/function : CD4520 dual 4-bit binary counter. Each counter has a
//                          CLOCK, an ENABLE, and an active-high RESET, with
//                          outputs Q0..Q3. On the real part a counter advances
//                          on the rising edge of CLOCK while ENABLE is high, or
//                          on the falling edge of ENABLE while CLOCK is high.
// FPGA modeling approach : two synchronous up-counters clocked by the FPGA
//                          clock. The CLOCK pin is edge-detected (rising) and
//                          gated by ENABLE high to advance the count — no gated
//                          clocks. Only the "rising CLOCK while ENABLE high"
//                          mode is modeled.
// Differences from the IC: the alternative "falling ENABLE while CLOCK high"
//                          clocking mode is not modeled (documented limitation).
//                          RESET is async on the real part; modeled synchronously.
// Parameters             : none
// Ports                  : clk, reset_n (FPGA clock + sync reset); per counter:
//                          clk_in (CLOCK), enable (ENABLE), reset (active high),
//                          q[3:0]
// Reset behavior         : reset_n low or a counter's reset high clears that
//                          counter to 0
// Synthesis notes        : single clock domain; reuses rtl/common/edge_detector.
// Verification status    : self-checking testbench tb_cd4520.
//
// Written from public behavioral descriptions. No copyrighted content.
// ----------------------------------------------------------------------------
module cd4520 (
    input  logic       clk,
    input  logic       reset_n,
    // Counter A
    input  logic       clk_a,
    input  logic       enable_a,
    input  logic       reset_a,
    output logic [3:0] q_a,
    // Counter B
    input  logic       clk_b,
    input  logic       enable_b,
    input  logic       reset_b,
    output logic [3:0] q_b
);

    logic clk_a_rise, clk_b_rise;

    edge_detector u_eda (
        .clk(clk), .reset_n(reset_n), .signal_in(clk_a),
        .rising_pulse(clk_a_rise), .falling_pulse(), .edge_pulse()
    );
    edge_detector u_edb (
        .clk(clk), .reset_n(reset_n), .signal_in(clk_b),
        .rising_pulse(clk_b_rise), .falling_pulse(), .edge_pulse()
    );

    always_ff @(posedge clk) begin
        if (!reset_n)                    q_a <= 4'd0;
        else if (reset_a)                q_a <= 4'd0;
        else if (clk_a_rise && enable_a) q_a <= q_a + 4'd1;
    end

    always_ff @(posedge clk) begin
        if (!reset_n)                    q_b <= 4'd0;
        else if (reset_b)                q_b <= 4'd0;
        else if (clk_b_rise && enable_b) q_b <= q_b + 4'd1;
    end

endmodule : cd4520
