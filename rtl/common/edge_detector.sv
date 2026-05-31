// ----------------------------------------------------------------------------
// edge_detector — rising/falling edge to single-cycle pulse
//
// Original chip/function : n/a (FPGA helper, not a vintage IC)
// FPGA modeling approach : register the input one cycle, compare to produce a
//                          one-clock pulse on the selected edge(s)
// Differences from the IC: n/a
// Parameters             : DETECT_RISING, DETECT_FALLING — select which edges
//                          drive the combined edge_pulse output
// Ports                  : clk, reset_n, signal_in; outputs rising_pulse,
//                          falling_pulse, edge_pulse (selected combination)
// Reset behavior         : history flop clears to 0 while reset_n low
// Synthesis notes        : single clock; used to turn external bus strobes
//                          (RD#, WR#, E) into internal one-cycle commit pulses.
// Verification status    : basic self-checking testbench in sim/common.
//
// Written from scratch. No copyrighted content.
// ----------------------------------------------------------------------------
module edge_detector #(
    parameter bit DETECT_RISING  = 1'b1,
    parameter bit DETECT_FALLING = 1'b0
) (
    input  logic clk,
    input  logic reset_n,
    input  logic signal_in,
    output logic rising_pulse,
    output logic falling_pulse,
    output logic edge_pulse
);

    logic signal_prev;

    always_ff @(posedge clk) begin
        if (!reset_n) signal_prev <= 1'b0;
        else          signal_prev <= signal_in;
    end

    always_comb begin
        rising_pulse  =  signal_in & ~signal_prev;
        falling_pulse = ~signal_in &  signal_prev;
        edge_pulse    = (DETECT_RISING  & rising_pulse)
                      | (DETECT_FALLING & falling_pulse);
    end

endmodule : edge_detector
