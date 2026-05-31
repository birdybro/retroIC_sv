// tb_eprom_2716 — self-checking testbench for the 2716 wrapper.
// Init loads the first 16 bytes (test_rom16.hex); checks read, ce_n/oe_n gating.
// Run under: verilator --binary --timing
`timescale 1ns/1ps
module tb_eprom_2716;

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
    logic        ce_n, oe_n, data_oe;
    logic [7:0]  data_out;

    eprom_2716 #(.INIT_FILE("test_rom16.hex")) dut (
        .clk(clk), .addr(addr), .ce_n(ce_n), .oe_n(oe_n),
        .data_out(data_out), .data_oe(data_oe)
    );

    initial begin
        ce_n = 1'b0; oe_n = 1'b0;
        for (int i = 0; i < 16; i++) begin
            addr = i[10:0]; #1;
            check(data_out, {i[3:0], i[3:0]}, $sformatf("2716 read @%0d", i));
            check(data_oe, 1'b1, $sformatf("2716 data_oe @%0d", i));
        end
        addr = 11'h004; ce_n = 1'b1; #1;
        check(data_oe, 1'b0, "2716 data_oe when ce_n=1");
        check(data_out, 8'h00, "2716 data_out 0 when deselected");
        ce_n = 1'b0; oe_n = 1'b1; #1;
        check(data_oe, 1'b0, "2716 data_oe when oe_n=1");

        if (error_count == 0) begin
            $display("PASS: tb_eprom_2716"); $finish;
        end else begin
            $display("FAIL: tb_eprom_2716 (%0d errors)", error_count); $fatal(1);
        end
    end
endmodule : tb_eprom_2716
