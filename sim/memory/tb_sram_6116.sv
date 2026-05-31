// tb_sram_6116 — self-checking testbench for the 6116 wrapper.
// Covers write/read, ce_n/oe_n/we_n gating, dout_oe bus-direction.
// Run under: verilator --binary --timing
`timescale 1ns/1ps
module tb_sram_6116;

    int error_count = 0;
    task automatic check(input logic [63:0] got, expected, input string label);
        if (got !== expected) begin
            $display("FAIL: %s got=%h exp=%h", label, got, expected);
            error_count++;
        end
    endtask

    logic        clk = 1'b0;
    always #5 clk = ~clk;

    logic [10:0] addr;
    logic [7:0]  din, dout;
    logic        ce_n, oe_n, we_n, dout_oe;

    sram_6116 dut (
        .clk(clk), .addr(addr), .din(din), .ce_n(ce_n), .oe_n(oe_n),
        .we_n(we_n), .dout(dout), .dout_oe(dout_oe)
    );

    task automatic wr(input logic [10:0] ad, input logic [7:0] d);
        addr = ad; din = d; ce_n = 1'b0; oe_n = 1'b1; we_n = 1'b0;
        @(posedge clk); #1; we_n = 1'b1;
    endtask

    initial begin
        ce_n = 1'b1; oe_n = 1'b1; we_n = 1'b1; din = '0; addr = '0;
        @(posedge clk);

        wr(11'h010, 8'h5A);
        wr(11'h7FF, 8'hC3);   // top address

        addr = 11'h010; ce_n = 1'b0; oe_n = 1'b0; we_n = 1'b1; #1;
        check(dout, 8'h5A, "6116 read @0x010");
        check(dout_oe, 1'b1, "6116 dout_oe on read");
        addr = 11'h7FF; #1;
        check(dout, 8'hC3, "6116 read @0x7FF (top)");

        ce_n = 1'b1; #1;
        check(dout_oe, 1'b0, "6116 dout_oe low when ce_n=1");
        ce_n = 1'b0; oe_n = 1'b1; #1;
        check(dout_oe, 1'b0, "6116 dout_oe low when oe_n=1");

        if (error_count == 0) begin
            $display("PASS: tb_sram_6116"); $finish;
        end else begin
            $display("FAIL: tb_sram_6116 (%0d errors)", error_count); $fatal(1);
        end
    end
endmodule : tb_sram_6116
