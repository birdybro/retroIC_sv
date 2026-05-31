// tb_eprom_2764 — self-checking testbench for the 2764 wrapper.
// Also exercises REGISTER_OUTPUT=1 (registered read, one-cycle latency).
// Run under: verilator --binary --timing
`timescale 1ns/1ps
module tb_eprom_2764;

    int error_count = 0;
    task automatic check(input logic [63:0] got, expected, input string label);
        if (got !== expected) begin
            $display("FAIL: %s got=%h exp=%h", label, got, expected);
            error_count++;
        end
    endtask

    logic        clk = 1'b0;
    always #5 clk = ~clk;

    // Async-read instance
    logic [12:0] a_addr;
    logic        a_ce_n, a_oe_n, a_oe;
    logic [7:0]  a_dout;
    eprom_2764 #(.INIT_FILE("test_rom16.hex")) dut_a (
        .clk(clk), .addr(a_addr), .ce_n(a_ce_n), .oe_n(a_oe_n),
        .data_out(a_dout), .data_oe(a_oe)
    );

    // Registered-read instance
    logic [12:0] r_addr;
    logic        r_ce_n, r_oe_n, r_oe;
    logic [7:0]  r_dout;
    eprom_2764 #(.INIT_FILE("test_rom16.hex"), .REGISTER_OUTPUT(1'b1)) dut_r (
        .clk(clk), .addr(r_addr), .ce_n(r_ce_n), .oe_n(r_oe_n),
        .data_out(r_dout), .data_oe(r_oe)
    );

    initial begin
        a_ce_n = 1'b0; a_oe_n = 1'b0;
        for (int i = 0; i < 16; i++) begin
            a_addr = i[12:0]; #1;
            check(a_dout, {i[3:0], i[3:0]}, $sformatf("2764 read @%0d", i));
        end
        a_addr = 13'h004; a_ce_n = 1'b1; #1;
        check(a_oe, 1'b0, "2764 data_oe when ce_n=1");

        // Registered read
        r_ce_n = 1'b0; r_oe_n = 1'b0; r_addr = 13'h006;
        @(posedge clk); #1;
        check(r_dout, 8'h66, "2764 registered read @6");
        check(r_oe, 1'b1, "2764 registered data_oe");

        if (error_count == 0) begin
            $display("PASS: tb_eprom_2764"); $finish;
        end else begin
            $display("FAIL: tb_eprom_2764 (%0d errors)", error_count); $fatal(1);
        end
    end
endmodule : tb_eprom_2764
