// ----------------------------------------------------------------------------
// eprom_2732 — 4K x 8 EPROM read-path model
//
// Original chip/function : 2732 4K x 8 UV EPROM, read path
// FPGA modeling approach : thin wrapper over generic_async_rom (ADDR_WIDTH=12,
//                          DATA_WIDTH=8). Contents from INIT_FILE via $readmemh.
// Differences from the IC: on the real 2732 the OE and Vpp functions share a
//                          pin (OE/Vpp); programming is not modeled. We model the
//                          read path with separate active-low oe_n. Outputs use
//                          data_out + data_oe instead of tri-state.
// Parameters             : INIT_FILE, REGISTER_OUTPUT (async vs registered read)
// Ports                  : clk (only if REGISTER_OUTPUT=1), addr[11:0], ce_n,
//                          oe_n, data_out[7:0], data_oe
// Reset behavior         : contents from INIT_FILE; data_out=0 when not enabled
// Synthesis notes        : see generic_async_rom.
// Verification status    : self-checking testbench tb_eprom_2732.
//
// Written from public behavioral descriptions. No ROM contents shipped.
// ----------------------------------------------------------------------------
module eprom_2732 #(
    parameter string INIT_FILE       = "",
    parameter bit    REGISTER_OUTPUT = 1'b0
) (
    input  logic        clk,
    input  logic [11:0] addr,
    input  logic        ce_n,
    input  logic        oe_n,
    output logic [7:0]  data_out,
    output logic        data_oe
);

    generic_async_rom #(
        .ADDR_WIDTH      (12),
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

endmodule : eprom_2732
