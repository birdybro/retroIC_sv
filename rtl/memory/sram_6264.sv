// ----------------------------------------------------------------------------
// sram_6264 — 8K x 8 static RAM model
//
// Original chip/function : 6264 8K x 8 asynchronous SRAM (common-I/O)
// FPGA modeling approach : thin wrapper over generic_sram (ADDR_WIDTH=13,
//                          DATA_WIDTH=8). Synchronous write on the FPGA clock,
//                          configurable async/sync read.
// Differences from the IC: the real 6264 has two chip selects, CS1# (active
//                          low) and CS2 (active high); the device is selected
//                          only when CS1#=0 AND CS2=1. We expose both pins and
//                          combine them internally. Writes commit on the FPGA
//                          clock edge while selected and write-enabled. Common-
//                          I/O modeled as din / dout / dout_oe. Power-up
//                          contents undefined on real parts.
// Parameters             : INIT_FILE — optional preload; SYNC_READ — async (0)
//                          vs registered (1) read
// Ports                  : clk, addr[12:0], din[7:0], cs1_n, cs2, oe_n, we_n,
//                          dout[7:0], dout_oe
// Reset behavior         : no content reset; dout=0 when not output-enabled
// Synthesis notes        : 64 Kbit — SYNC_READ recommended for M10K.
// Verification status    : self-checking testbench tb_sram_6264.
//
// Written from public behavioral descriptions. No copyrighted content.
// ----------------------------------------------------------------------------
module sram_6264 #(
    parameter string INIT_FILE = "",
    parameter bit    SYNC_READ = 1'b0
) (
    input  logic        clk,
    input  logic [12:0] addr,
    input  logic [7:0]  din,
    input  logic        cs1_n,    // active-low chip select 1
    input  logic        cs2,      // active-high chip select 2
    input  logic        oe_n,
    input  logic        we_n,
    output logic [7:0]  dout,
    output logic        dout_oe
);

    // Selected only when CS1# is low AND CS2 is high.
    logic ce_n;
    always_comb ce_n = cs1_n | ~cs2;

    generic_sram #(
        .ADDR_WIDTH  (13),
        .DATA_WIDTH  (8),
        .BYTE_ENABLE (1'b0),
        .SYNC_READ   (SYNC_READ),
        .INIT_FILE   (INIT_FILE)
    ) u_ram (
        .clk     (clk),
        .addr    (addr),
        .din     (din),
        .ce_n    (ce_n),
        .oe_n    (oe_n),
        .we_n    (we_n),
        .byte_en (1'b1),
        .dout    (dout),
        .dout_oe (dout_oe)
    );

endmodule : sram_6264
