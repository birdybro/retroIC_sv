// ----------------------------------------------------------------------------
// generic_async_rom — parameterized ROM base used by all EPROM wrappers
//
// Original chip/function : generic mask/EPROM read path (address in, data out)
// FPGA modeling approach : unpacked-array storage initialized from a hex file
//                          via $readmemh. Read is either asynchronous
//                          (combinational, REGISTER_OUTPUT=0) or registered
//                          (one-cycle latency, REGISTER_OUTPUT=1).
// Differences from the IC: real EPROMs are fully asynchronous and have access-
//                          time delays, multiple supply rails, and shared
//                          OE/Vpp pins. We model only the digital read path with
//                          active-low ce_n/oe_n. No internal tri-state: the
//                          chip exposes data_out + data_oe (see
//                          docs/tri_state_modeling.md).
// Parameters             : ADDR_WIDTH      — address bits (depth = 2**ADDR_WIDTH)
//                          DATA_WIDTH      — output word width
//                          INIT_FILE       — $readmemh path ("" = uninitialized)
//                          REGISTER_OUTPUT — 0 async read, 1 registered read
// Ports                  : clk (used only when REGISTER_OUTPUT=1), addr,
//                          ce_n, oe_n, data_out, data_oe
// Reset behavior         : ROM contents come from INIT_FILE; there is no
//                          run-time reset of contents. data_out forced to 0 when
//                          not output-enabled (deterministic, not high-Z).
// Synthesis notes        : REGISTER_OUTPUT=0 infers LUT/distributed memory (good
//                          for small ROMs); REGISTER_OUTPUT=1 infers block RAM
//                          (M10K) with one-cycle read latency (good for large
//                          ROMs). See docs/memory_models.md.
// Verification status    : self-checking testbench tb_generic_async_rom.
//
// Written from public behavioral descriptions. No ROM contents shipped.
// ----------------------------------------------------------------------------
module generic_async_rom #(
    parameter int    ADDR_WIDTH      = 11,
    parameter int    DATA_WIDTH      = 8,
    parameter string INIT_FILE       = "",
    parameter bit    REGISTER_OUTPUT = 1'b0
) (
    input  logic                  clk,
    input  logic [ADDR_WIDTH-1:0] addr,
    input  logic                  ce_n,
    input  logic                  oe_n,
    output logic [DATA_WIDTH-1:0] data_out,
    output logic                  data_oe
);

    localparam int DEPTH = 1 << ADDR_WIDTH;

    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    initial begin
        if (INIT_FILE != "")
            $readmemh(INIT_FILE, mem);
    end

    // Output drivers are active only when selected and output-enabled.
    always_comb data_oe = (~ce_n) & (~oe_n);

    logic [DATA_WIDTH-1:0] read_data;

    generate
        if (REGISTER_OUTPUT) begin : g_registered_read
            logic [DATA_WIDTH-1:0] read_data_q;
            always_ff @(posedge clk)
                read_data_q <= mem[addr];
            assign read_data = read_data_q;
        end else begin : g_async_read
            assign read_data = mem[addr];
        end
    endgenerate

    // Deterministic value when not driving (no internal high-Z).
    always_comb data_out = data_oe ? read_data : '0;

endmodule : generic_async_rom
