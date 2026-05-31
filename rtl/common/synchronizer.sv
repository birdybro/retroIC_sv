// ----------------------------------------------------------------------------
// synchronizer — N-stage input synchronizer
//
// Original chip/function : n/a (FPGA helper, not a vintage IC)
// FPGA modeling approach : chain of STAGES flip-flops to bring an asynchronous
//                          board signal into the FPGA clock domain
// Differences from the IC: n/a
// Parameters             : STAGES — flop count (default 2); WIDTH — bus width;
//                          RESET_VALUE — value held while reset_n is low
// Ports                  : clk, reset_n (active-low sync reset), async_in,
//                          sync_out
// Reset behavior         : all stages load RESET_VALUE while reset_n low
// Synthesis notes        : single clock; no gated clocks; intended for 1-bit
//                          control signals. For multi-bit data crossings prefer
//                          a proper CDC scheme (handshake / async FIFO).
// Verification status    : basic self-checking testbench in sim/common.
//
// Written from scratch. No copyrighted content.
// ----------------------------------------------------------------------------
module synchronizer #(
    parameter int               STAGES      = 2,
    parameter int               WIDTH       = 1,
    parameter logic [WIDTH-1:0] RESET_VALUE = '0
) (
    input  logic             clk,
    input  logic             reset_n,
    input  logic [WIDTH-1:0] async_in,
    output logic [WIDTH-1:0] sync_out
);

    logic [WIDTH-1:0] sync_ff [0:STAGES-1];

    always_ff @(posedge clk) begin
        if (!reset_n) begin
            for (int s = 0; s < STAGES; s++)
                sync_ff[s] <= RESET_VALUE;
        end else begin
            sync_ff[0] <= async_in;
            for (int s = 1; s < STAGES; s++)
                sync_ff[s] <= sync_ff[s-1];
        end
    end

    assign sync_out = sync_ff[STAGES-1];

endmodule : synchronizer
