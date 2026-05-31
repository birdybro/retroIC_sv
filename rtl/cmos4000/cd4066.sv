// ----------------------------------------------------------------------------
// cd4066 — quad bilateral switch (digital model)
//
// Original chip/function : CD4066 four independent analog switches; each closes
//                          (conducts between its two pins) when its CONTROL
//                          input is high.
// FPGA modeling approach : four independent DIGITAL switches. Each switch passes
//                          its input a[i] to output y[i] when control[i] is high,
//                          and exposes y_oe[i] = control[i] so an integrator can
//                          build a mux/wired bus without internal tri-state
//                          (see docs/tri_state_modeling.md). When open, y[i]=0
//                          and y_oe[i]=0.
// Differences from the IC: NO analog behavior — no on-resistance, no true
//                          bidirectional conduction, no analog signal range. The
//                          model is a unidirectional a -> y digital pass gate
//                          with an enable. If you need the reverse direction,
//                          instantiate a second switch or mux on y_oe.
// Parameters             : none
// Ports                  : a[3:0] (switch inputs), control[3:0] (active high),
//                          y[3:0] (switch outputs), y_oe[3:0] (switch closed)
// Reset behavior         : none (combinational)
// Synthesis notes        : combinational; no internal tri-state.
// Verification status    : self-checking testbench tb_cd4066.
//
// Written from public behavioral descriptions. No copyrighted content.
// ----------------------------------------------------------------------------
module cd4066 (
    input  logic [3:0] a,
    input  logic [3:0] control,
    output logic [3:0] y,
    output logic [3:0] y_oe
);

    always_comb begin
        for (int i = 0; i < 4; i++) begin
            y[i]    = control[i] ? a[i] : 1'b0;
            y_oe[i] = control[i];
        end
    end

endmodule : cd4066
