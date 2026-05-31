// ----------------------------------------------------------------------------
// cd4051 — 8:1 mux / 1:8 demux (digital model of the analog switch)
//
// Original chip/function : CD4051 single-pole 8-throw analog switch used as an
//                          8:1 mux or 1:8 demux, with 3 select inputs (A,B,C)
//                          and an active-high INHIBIT that opens all switches.
// FPGA modeling approach : purely combinational DIGITAL mux/demux. Because the
//                          real device is a bidirectional analog switch, the
//                          digital model splits the single common pin into a
//                          mux path (channels -> common_out) and a demux path
//                          (common_in -> channels). Pick whichever direction
//                          your core uses.
// Differences from the IC: NO analog behavior — no on-resistance, no charge
//                          injection, no true bidirectional conduction, no
//                          negative-rail (VEE) signal range. Digital logic only.
//                          When INHIBIT is high all outputs read 0 (open).
// Parameters             : none
// Ports                  : select[2:0] (A,B,C), inhibit (active high);
//                          mux:   channel_in[7:0] -> common_out
//                          demux: common_in       -> channel_out[7:0]
// Reset behavior         : none (combinational)
// Synthesis notes        : combinational; variable index select.
// Verification status    : self-checking testbench tb_cd4051.
//
// Written from public behavioral descriptions. No copyrighted content.
// ----------------------------------------------------------------------------
module cd4051 (
    input  logic [2:0] select,
    input  logic       inhibit,
    // Mux direction: one of eight channels onto the common output.
    input  logic [7:0] channel_in,
    output logic       common_out,
    // Demux direction: common input onto the selected channel output.
    input  logic       common_in,
    output logic [7:0] channel_out
);

    always_comb begin
        // Mux path
        common_out = (!inhibit) ? channel_in[select] : 1'b0;

        // Demux path (selected channel follows common_in, others 0)
        channel_out = '0;
        if (!inhibit)
            channel_out[select] = common_in;
    end

endmodule : cd4051
