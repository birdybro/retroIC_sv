// tb_sram_6264 — self-checking testbench for the 6264 wrapper.
// Covers write/read, dual chip-select (CS1#, CS2), oe_n/we_n gating, dout_oe.
// Run under: verilator --binary --timing
`timescale 1ns/1ps
module tb_sram_6264;

    int error_count = 0;
    task automatic check(input logic [63:0] got, expected, input string label);
        if (got !== expected) begin
            $display("FAIL: %s got=%h exp=%h", label, got, expected);
            error_count++;
        end
    endtask

    logic        clk = 1'b0;
    always #5 clk = ~clk;

    logic [12:0] addr;
    logic [7:0]  din, dout;
    logic        cs1_n, cs2, oe_n, we_n, dout_oe;

    sram_6264 dut (
        .clk(clk), .addr(addr), .din(din), .cs1_n(cs1_n), .cs2(cs2),
        .oe_n(oe_n), .we_n(we_n), .dout(dout), .dout_oe(dout_oe)
    );

    // Write requires both selects active: cs1_n=0 AND cs2=1.
    task automatic wr(input logic [12:0] ad, input logic [7:0] d);
        addr = ad; din = d; cs1_n = 1'b0; cs2 = 1'b1; oe_n = 1'b1; we_n = 1'b0;
        @(posedge clk); #1; we_n = 1'b1;
    endtask

    initial begin
        cs1_n = 1'b1; cs2 = 1'b0; oe_n = 1'b1; we_n = 1'b1; din = '0; addr = '0;
        @(posedge clk);

        wr(13'h0020, 8'h11);
        wr(13'h1FFF, 8'hEE);  // top address

        addr = 13'h0020; cs1_n = 1'b0; cs2 = 1'b1; oe_n = 1'b0; we_n = 1'b1; #1;
        check(dout, 8'h11, "6264 read @0x0020");
        check(dout_oe, 1'b1, "6264 dout_oe on read");
        addr = 13'h1FFF; #1;
        check(dout, 8'hEE, "6264 read @0x1FFF (top)");

        // Deselect via CS2 low — must not drive, and a write must be ignored.
        cs2 = 1'b0; #1;
        check(dout_oe, 1'b0, "6264 dout_oe low when cs2=0");
        addr = 13'h0020; din = 8'hAA; cs1_n = 1'b0; cs2 = 1'b0; we_n = 1'b0;
        @(posedge clk); #1; we_n = 1'b1;
        cs2 = 1'b1; oe_n = 1'b0; addr = 13'h0020; #1;
        check(dout, 8'h11, "6264 write ignored while deselected");

        // Deselect via CS1# high
        cs1_n = 1'b1; #1;
        check(dout_oe, 1'b0, "6264 dout_oe low when cs1_n=1");

        if (error_count == 0) begin
            $display("PASS: tb_sram_6264"); $finish;
        end else begin
            $display("FAIL: tb_sram_6264 (%0d errors)", error_count); $fatal(1);
        end
    end
endmodule : tb_sram_6264
