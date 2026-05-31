// ----------------------------------------------------------------------------
// sram_6116 — 2K x 8 static RAM model
//
// Original chip/function : 6116 2K x 8 asynchronous SRAM (common-I/O)
// FPGA modeling approach : thin wrapper over generic_sram (ADDR_WIDTH=11,
//                          DATA_WIDTH=8). Synchronous write on the FPGA clock,
//                          configurable async/sync read.
// Differences from the IC: real part is fully asynchronous; here writes commit
//                          on the clock edge while selected and write-enabled.
//                          Common-I/O is modeled as din / dout / dout_oe (no
//                          internal tri-state). Power-up contents undefined on
//                          real parts.
// Parameters             : INIT_FILE — optional preload; SYNC_READ — async (0)
//                          vs registered (1) read
// Ports                  : clk, addr[10:0], din[7:0], ce_n, oe_n, we_n,
//                          dout[7:0], dout_oe
// Reset behavior         : no content reset; dout=0 when not output-enabled
// Synthesis notes        : see generic_sram; SYNC_READ for M10K, async for
//                          distributed RAM.
// Verification status    : self-checking testbench tb_sram_6116.
//
// Written from public behavioral descriptions. No copyrighted content.
// ----------------------------------------------------------------------------
module sram_6116 #(
    parameter string INIT_FILE = "",
    parameter bit    SYNC_READ = 1'b0
) (
    input  logic        clk,
    input  logic [10:0] addr,
    input  logic [7:0]  din,
    input  logic        ce_n,
    input  logic        oe_n,
    input  logic        we_n,
    output logic [7:0]  dout,
    output logic        dout_oe
);

    generic_sram #(
        .ADDR_WIDTH  (11),
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
        .byte_en (1'b1),       // single byte, always enabled
        .dout    (dout),
        .dout_oe (dout_oe)
    );

endmodule : sram_6116
