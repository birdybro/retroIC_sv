// ----------------------------------------------------------------------------
// generic_sram — parameterized static RAM base used by all SRAM wrappers
//
// Original chip/function : generic asynchronous static RAM (common-I/O)
// FPGA modeling approach : unpacked-array storage with synchronous write and a
//                          configurable asynchronous (combinational) or
//                          synchronous (registered) read. Bidirectional common-
//                          I/O is modeled with separate din / dout / dout_oe
//                          (no internal tri-state; see docs/tri_state_modeling.md).
// Differences from the IC: real SRAM is fully asynchronous and writes on the
//                          CE/WE strobe edges; here the write commits on the
//                          FPGA clock edge while selected and write-enabled
//                          (clean single-clock behavior). Power-up contents are
//                          undefined on real parts; here they come from INIT_FILE
//                          (or are X in sim) unless your core clears them.
// Parameters             : ADDR_WIDTH  — address bits (depth = 2**ADDR_WIDTH)
//                          DATA_WIDTH  — word width
//                          BYTE_ENABLE — 1 enables per-byte write masking
//                          SYNC_READ   — 0 async read, 1 registered read
//                          INIT_FILE   — optional $readmemh preload ("" = none)
// Ports                  : clk, addr, din, ce_n, oe_n, we_n, byte_en[],
//                          dout, dout_oe
// Reset behavior         : no reset of contents; dout forced to 0 when not
//                          output-enabled (deterministic, not high-Z).
// Synthesis notes        : SYNC_READ=0 infers LUT/distributed RAM; SYNC_READ=1
//                          infers block RAM (M10K) with one-cycle read latency.
//                          BYTE_ENABLE expects DATA_WIDTH a multiple of 8.
// Verification status    : self-checking testbench tb_generic_sram.
//
// Written from public behavioral descriptions. No copyrighted content.
// ----------------------------------------------------------------------------
module generic_sram #(
    parameter int    ADDR_WIDTH  = 11,
    parameter int    DATA_WIDTH  = 8,
    parameter bit    BYTE_ENABLE = 1'b0,
    parameter bit    SYNC_READ   = 1'b0,
    parameter string INIT_FILE   = ""
) (
    input  logic                            clk,
    input  logic [ADDR_WIDTH-1:0]           addr,
    input  logic [DATA_WIDTH-1:0]           din,
    input  logic                            ce_n,
    input  logic                            oe_n,
    input  logic                            we_n,
    input  logic [((DATA_WIDTH+7)/8)-1:0]   byte_en,
    output logic [DATA_WIDTH-1:0]           dout,
    output logic                            dout_oe
);

    localparam int DEPTH     = 1 << ADDR_WIDTH;
    localparam int NUM_BYTES = (DATA_WIDTH + 7) / 8;

    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    initial begin
        if (INIT_FILE != "")
            $readmemh(INIT_FILE, mem);
    end

    // Selected and write-enabled. Write commits on the clock edge.
    logic write_en;
    always_comb write_en = (~ce_n) & (~we_n);

    // Output driven when selected, output-enabled, and not writing.
    always_comb dout_oe = (~ce_n) & (~oe_n) & we_n;

    // --- Write port -----------------------------------------------------------
    generate
        if (BYTE_ENABLE) begin : g_byte_write
            always_ff @(posedge clk) begin
                if (write_en) begin
                    for (int b = 0; b < NUM_BYTES; b++) begin
                        if (byte_en[b])
                            mem[addr][b*8 +: 8] <= din[b*8 +: 8];
                    end
                end
            end
        end else begin : g_word_write
            always_ff @(posedge clk) begin
                if (write_en)
                    mem[addr] <= din;
            end
        end
    endgenerate

    // --- Read port ------------------------------------------------------------
    logic [DATA_WIDTH-1:0] read_data;
    generate
        if (SYNC_READ) begin : g_sync_read
            logic [DATA_WIDTH-1:0] read_data_q;
            always_ff @(posedge clk)
                read_data_q <= mem[addr];
            assign read_data = read_data_q;
        end else begin : g_async_read
            assign read_data = mem[addr];
        end
    endgenerate

    always_comb dout = dout_oe ? read_data : '0;

endmodule : generic_sram
