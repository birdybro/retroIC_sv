// ----------------------------------------------------------------------------
// eprom_2764 — 8K x 8 EPROM read-path model
//
// Original chip/function : 2764 8K x 8 UV EPROM, read path
// FPGA modeling approach : thin wrapper over generic_async_rom (ADDR_WIDTH=13,
//                          DATA_WIDTH=8). Contents from INIT_FILE via $readmemh.
// Differences from the IC: the real 2764 has CE#, OE#, and PGM# pins plus Vpp;
//                          programming and standby are not modeled. We model the
//                          read path: ce_n (chip enable) and oe_n (output
//                          enable). Outputs use data_out + data_oe.
// Parameters             : INIT_FILE, REGISTER_OUTPUT (async vs registered read)
// Ports                  : clk (only if REGISTER_OUTPUT=1), addr[12:0], ce_n,
//                          oe_n, data_out[7:0], data_oe
// Reset behavior         : contents from INIT_FILE; data_out=0 when not enabled
// Synthesis notes        : 64 Kbit — registered output recommended for M10K.
// Verification status    : self-checking testbench tb_eprom_2764.
//
// Written from public behavioral descriptions. No ROM contents shipped.
// ----------------------------------------------------------------------------
module eprom_2764 #(
    parameter string INIT_FILE       = "",
    parameter bit    REGISTER_OUTPUT = 1'b0
) (
    input  logic        clk,
    input  logic [12:0] addr,
    input  logic        ce_n,
    input  logic        oe_n,
    output logic [7:0]  data_out,
    output logic        data_oe
);

    generic_async_rom #(
        .ADDR_WIDTH      (13),
        .DATA_WIDTH      (8),
        .INIT_FILE       (INIT_FILE),
        .REGISTER_OUTPUT (REGISTER_OUTPUT)
    ) u_rom (
        .clk      (clk),
        .addr     (addr),
        .ce_n     (ce_n),
        .oe_n     (oe_n),
        .data_out (data_out),
        .data_oe  (data_oe)
    );

endmodule : eprom_2764
