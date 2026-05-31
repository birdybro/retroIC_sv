// tb_generic_sram — self-checking testbench for generic_sram.
// Covers: synchronous write, async + sync read, chip-enable / output-enable /
// write-enable gating, dout_oe bus-direction, and byte-enable masking.
// Run under: verilator --binary --timing
`timescale 1ns/1ps
module tb_generic_sram;

    int error_count = 0;

    task automatic check(input logic [63:0] got, expected, input string label);
        if (got !== expected) begin
            $display("FAIL: %s got=%h exp=%h", label, got, expected);
            error_count++;
        end
    endtask

    logic clk = 1'b0;
    always #5 clk = ~clk;

    // --- Async-read 16x8 DUT --------------------------------------------------
    logic [3:0] a_addr;
    logic [7:0] a_din, a_dout;
    logic       a_ce_n, a_oe_n, a_we_n, a_oe;

    generic_sram #(
        .ADDR_WIDTH(4), .DATA_WIDTH(8), .BYTE_ENABLE(1'b0), .SYNC_READ(1'b0)
    ) dut_async (
        .clk(clk), .addr(a_addr), .din(a_din), .ce_n(a_ce_n), .oe_n(a_oe_n),
        .we_n(a_we_n), .byte_en(1'b1), .dout(a_dout), .dout_oe(a_oe)
    );

    // --- Sync-read 16x8 DUT ---------------------------------------------------
    logic [3:0] s_addr;
    logic [7:0] s_din, s_dout;
    logic       s_ce_n, s_oe_n, s_we_n, s_oe;

    generic_sram #(
        .ADDR_WIDTH(4), .DATA_WIDTH(8), .BYTE_ENABLE(1'b0), .SYNC_READ(1'b1)
    ) dut_sync (
        .clk(clk), .addr(s_addr), .din(s_din), .ce_n(s_ce_n), .oe_n(s_oe_n),
        .we_n(s_we_n), .byte_en(1'b1), .dout(s_dout), .dout_oe(s_oe)
    );

    // --- Byte-enable 8x16 DUT -------------------------------------------------
    logic [2:0]  b_addr;
    logic [15:0] b_din, b_dout;
    logic [1:0]  b_byte_en;
    logic        b_ce_n, b_oe_n, b_we_n, b_oe;

    generic_sram #(
        .ADDR_WIDTH(3), .DATA_WIDTH(16), .BYTE_ENABLE(1'b1), .SYNC_READ(1'b0)
    ) dut_byte (
        .clk(clk), .addr(b_addr), .din(b_din), .ce_n(b_ce_n), .oe_n(b_oe_n),
        .we_n(b_we_n), .byte_en(b_byte_en), .dout(b_dout), .dout_oe(b_oe)
    );

    // Write one word into the async DUT (synchronous write).
    task automatic wr_async(input logic [3:0] ad, input logic [7:0] d);
        a_addr = ad; a_din = d; a_ce_n = 1'b0; a_oe_n = 1'b1; a_we_n = 1'b0;
        @(posedge clk); #1;
        a_we_n = 1'b1;                       // end write
    endtask

    initial begin
        a_ce_n = 1'b1; a_oe_n = 1'b1; a_we_n = 1'b1; a_din = '0; a_addr = '0;
        s_ce_n = 1'b1; s_oe_n = 1'b1; s_we_n = 1'b1; s_din = '0; s_addr = '0;
        b_ce_n = 1'b1; b_oe_n = 1'b1; b_we_n = 1'b1; b_din = '0; b_addr = '0;
        b_byte_en = 2'b00;
        @(posedge clk);

        // ---- Async write then read back ----
        wr_async(4'h2, 8'hA5);
        wr_async(4'hF, 8'h3C);
        // read 0x2
        a_addr = 4'h2; a_ce_n = 1'b0; a_oe_n = 1'b0; a_we_n = 1'b1; #1;
        check(a_dout, 8'hA5, "async read @2");
        check(a_oe, 1'b1, "async dout_oe on read");
        // read 0xF
        a_addr = 4'hF; #1;
        check(a_dout, 8'h3C, "async read @F");

        // ---- dout_oe gating ----
        a_ce_n = 1'b1; #1;
        check(a_oe, 1'b0, "dout_oe low when ce_n=1");
        check(a_dout, 8'h00, "dout 0 when deselected");
        a_ce_n = 1'b0; a_oe_n = 1'b1; #1;
        check(a_oe, 1'b0, "dout_oe low when oe_n=1");
        a_oe_n = 1'b0; a_we_n = 1'b0; #1;       // writing: outputs off
        check(a_oe, 1'b0, "dout_oe low during write");
        a_we_n = 1'b1; #1;

        // ---- Deselected write is ignored ----
        a_addr = 4'h2; a_din = 8'hEE; a_ce_n = 1'b1; a_we_n = 1'b0;
        @(posedge clk); #1;
        a_ce_n = 1'b0; a_oe_n = 1'b0; a_we_n = 1'b1; a_addr = 4'h2; #1;
        check(a_dout, 8'hA5, "deselected write ignored @2");

        // ---- Sync read: write then read with one-cycle latency ----
        s_addr = 4'h7; s_din = 8'h99; s_ce_n = 1'b0; s_oe_n = 1'b1; s_we_n = 1'b0;
        @(posedge clk); #1; s_we_n = 1'b1;
        s_addr = 4'h7; s_oe_n = 1'b0;             // present read address
        @(posedge clk); #1;                        // registered data appears
        check(s_dout, 8'h99, "sync read @7 after latency");
        check(s_oe, 1'b1, "sync dout_oe on read");

        // ---- Byte enable: write only low byte, then only high byte ----
        b_addr = 3'h1; b_ce_n = 1'b0; b_oe_n = 1'b1;
        b_din = 16'hBEEF; b_byte_en = 2'b01; b_we_n = 1'b0;   // low byte only
        @(posedge clk); #1; b_we_n = 1'b1;
        b_oe_n = 1'b0; b_we_n = 1'b1; #1;
        check(b_dout, 16'h00EF, "byte-enable low byte only");
        b_din = 16'hBEEF; b_byte_en = 2'b10; b_oe_n = 1'b1; b_we_n = 1'b0; // high byte
        @(posedge clk); #1; b_we_n = 1'b1;
        b_oe_n = 1'b0; #1;
        check(b_dout, 16'hBEEF, "byte-enable high byte completes word");

        if (error_count == 0) begin
            $display("PASS: tb_generic_sram");
            $finish;
        end else begin
            $display("FAIL: tb_generic_sram (%0d errors)", error_count);
            $fatal(1);
        end
    end

endmodule : tb_generic_sram
