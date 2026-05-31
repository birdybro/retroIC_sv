// tb_generic_async_rom — self-checking testbench for generic_async_rom.
// Covers: $readmemh init, async read truth, chip-enable / output-enable gating,
// data_oe bus-direction, and registered-read one-cycle latency.
// Run under: verilator --binary --timing
`timescale 1ns/1ps
module tb_generic_async_rom;

    localparam int AW = 4;   // 16-entry test ROM matches test_rom16.hex
    localparam int DW = 8;

    int error_count = 0;

    task automatic check(input logic [63:0] got, expected, input string label);
        if (got !== expected) begin
            $display("FAIL: %s got=%h exp=%h", label, got, expected);
            error_count++;
        end
    endtask

    logic           clk = 1'b0;
    always #5 clk = ~clk;

    // --- Async-read DUT -------------------------------------------------------
    logic [AW-1:0]  a_addr;
    logic           a_ce_n, a_oe_n;
    logic [DW-1:0]  a_dout;
    logic           a_oe;

    generic_async_rom #(
        .ADDR_WIDTH(AW), .DATA_WIDTH(DW),
        .INIT_FILE("test_rom16.hex"), .REGISTER_OUTPUT(1'b0)
    ) dut_async (
        .clk(clk), .addr(a_addr), .ce_n(a_ce_n), .oe_n(a_oe_n),
        .data_out(a_dout), .data_oe(a_oe)
    );

    // --- Registered-read DUT --------------------------------------------------
    logic [AW-1:0]  r_addr;
    logic           r_ce_n, r_oe_n;
    logic [DW-1:0]  r_dout;
    logic           r_oe;

    generic_async_rom #(
        .ADDR_WIDTH(AW), .DATA_WIDTH(DW),
        .INIT_FILE("test_rom16.hex"), .REGISTER_OUTPUT(1'b1)
    ) dut_reg (
        .clk(clk), .addr(r_addr), .ce_n(r_ce_n), .oe_n(r_oe_n),
        .data_out(r_dout), .data_oe(r_oe)
    );

    initial begin
        // ---- Async read: enabled, sweep all addresses ----
        a_ce_n = 1'b0; a_oe_n = 1'b0;
        for (int i = 0; i < 16; i++) begin
            a_addr = i[AW-1:0];
            #1;
            check(a_dout, {i[3:0], i[3:0]}, $sformatf("async data @%0d", i));
            check(a_oe, 1'b1, $sformatf("async data_oe @%0d", i));
        end

        // ---- Chip disabled: no drive, deterministic 0 ----
        a_addr = 4'h5; a_ce_n = 1'b1; a_oe_n = 1'b0; #1;
        check(a_oe,  1'b0, "async data_oe when ce_n=1");
        check(a_dout, 8'h00, "async data_out forced 0 when deselected");

        // ---- Output disabled ----
        a_ce_n = 1'b0; a_oe_n = 1'b1; #1;
        check(a_oe,  1'b0, "async data_oe when oe_n=1");
        check(a_dout, 8'h00, "async data_out forced 0 when oe_n=1");

        // ---- Registered read: one-cycle latency ----
        r_ce_n = 1'b0; r_oe_n = 1'b0;
        r_addr = 4'h3;
        @(posedge clk); #1;                 // data clocked through
        check(r_dout, 8'h33, "registered data after one clock @3");
        check(r_oe, 1'b1, "registered data_oe @3");
        r_addr = 4'hA;
        @(posedge clk); #1;
        check(r_dout, 8'hAA, "registered data after one clock @A");

        if (error_count == 0) begin
            $display("PASS: tb_generic_async_rom");
            $finish;
        end else begin
            $display("FAIL: tb_generic_async_rom (%0d errors)", error_count);
            $fatal(1);
        end
    end

endmodule : tb_generic_async_rom
