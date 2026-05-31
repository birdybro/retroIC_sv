// ----------------------------------------------------------------------------
// retro_ic_pkg — library-wide package
//
// Original chip/function : n/a (shared definitions for the retroIC_sv library)
// FPGA modeling approach : constants + small helper functions used across models
// Differences from the IC: n/a
// Parameters             : n/a
// Ports                  : n/a
// Reset behavior         : n/a
// Synthesis notes        : pure compile-time package; no logic.
// Verification status    : exercised indirectly by modules that import it.
//
// Written from scratch for this library. No copyrighted content.
// ----------------------------------------------------------------------------
package retro_ic_pkg;

    // Library version tag.
    localparam string RETRO_IC_VERSION = "0.1.0";

    // Readability constants for active-low control signals.
    localparam logic ACTIVE_LOW_ASSERTED   = 1'b0;
    localparam logic ACTIVE_LOW_DEASSERTED  = 1'b1;

    // Ceiling of a/b for positive integers (compile-time sizing helper).
    function automatic int unsigned ceil_div(input int unsigned a,
                                              input int unsigned b);
        ceil_div = (a + b - 1) / b;
    endfunction

endpackage : retro_ic_pkg
