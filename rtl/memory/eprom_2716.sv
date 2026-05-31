// ----------------------------------------------------------------------------
// eprom_2716 — 2K x 8 EPROM read-path model
//
// Original chip/function : 2716 2K x 8 UV EPROM (single +5 V variant), read path
// FPGA modeling approach : thin wrapper over generic_async_rom (ADDR_WIDTH=11,
//                          DATA_WIDTH=8). Contents from INIT_FILE via $readmemh.
// Differences from the IC: programming (Vpp), access-time delays, and the
//                          PD/PGM standby pin are not modeled. Outputs use
//                          data_out + data_oe instead of tri-state.
// Parameters             : INIT_FILE — $readmemh path; REGISTER_OUTPUT — async
//                          (0) vs registered (1) read
// Ports                  : clk (only used if REGISTER_OUTPUT=1), addr[10:0],
//                          ce_n, oe_n, data_out[7:0], data_oe
// Reset behavior         : contents from INIT_FILE; data_out=0 when not enabled
// Synthesis notes        : see generic_async_rom; small enough for LUT ROM, or
//                          registered for M10K.
// Verification status    : self-checking testbench tb_eprom_2716.
//
// Written from public behavioral descriptions. No ROM contents shipped.
// ----------------------------------------------------------------------------
module eprom_2716 #(
    parameter string INIT_FILE       = "",
    parameter bit    REGISTER_OUTPUT = 1'b0
) (
    input  logic        clk,
    input  logic [10:0] addr,
    input  logic        ce_n,
    input  logic        oe_n,
    output logic [7:0]  data_out,
    output logic        data_oe
);

    generic_async_rom #(
        .ADDR_WIDTH      (11),
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

endmodule : eprom_2716
