// tb_cd4013 — self-checking testbench for the dual D flip-flop.
// Covers: reset, edge-triggered D capture, async set/reset levels, both-high
// case, and independence of the two flip-flops.
// Convention: every stimulus change happens 1ns after a posedge to avoid
// clock/data races at the edge detector; checks follow a settled posedge.
// Run under: verilator --binary --timing
`timescale 1ns/1ps
module tb_cd4013;

    int error_count = 0;
    task automatic check(input logic [63:0] got, expected, input string label);
        if (got !== expected) begin
            $display("FAIL: %s got=%h exp=%h", label, got, expected);
            error_count++;
        end
    endtask

    logic clk = 1'b0;
    always #5 clk = ~clk;

    logic reset_n;
    logic d1, clk1, set1, reset1, q1, q1_n;
    logic d2, clk2, set2, reset2, q2, q2_n;

    cd4013 dut (
        .clk(clk), .reset_n(reset_n),
        .d1(d1), .clk1(clk1), .set1(set1), .reset1(reset1), .q1(q1), .q1_n(q1_n),
        .d2(d2), .clk2(clk2), .set2(set2), .reset2(reset2), .q2(q2), .q2_n(q2_n)
    );

    // Rising-edge tick on FF1's clock, capturing data value dv.
    task automatic tick1(input logic dv);
        @(posedge clk); #1; d1 = dv; clk1 = 1'b0;
        @(posedge clk); #1; clk1 = 1'b1;   // rising edge presented
        @(posedge clk); #1;                // captured at this edge
    endtask

    initial begin
        reset_n = 1'b0;
        d1 = 0; clk1 = 0; set1 = 0; reset1 = 0;
        d2 = 0; clk2 = 0; set2 = 0; reset2 = 0;
        @(posedge clk); #1;
        check(q1, 1'b0, "reset q1=0");
        check(q1_n, 1'b1, "reset q1_n=1");

        @(posedge clk); #1; reset_n = 1'b1;

        tick1(1'b1);
        check(q1, 1'b1, "clock D=1 -> q1=1");
        check(q1_n, 1'b0, "clock D=1 -> q1_n=0");

        tick1(1'b0);
        check(q1, 1'b0, "clock D=0 -> q1=0");
        check(q1_n, 1'b1, "clock D=0 -> q1_n=1");

        // Async SET (level)
        @(posedge clk); #1; set1 = 1'b1;
        @(posedge clk); #1;
        check(q1, 1'b1, "set1 -> q1=1");
        check(q1_n, 1'b0, "set1 -> q1_n=0");
        @(posedge clk); #1; set1 = 1'b0;

        // Async RESET (level)
        @(posedge clk); #1; reset1 = 1'b1;
        @(posedge clk); #1;
        check(q1, 1'b0, "reset1 -> q1=0");
        check(q1_n, 1'b1, "reset1 -> q1_n=1");
        @(posedge clk); #1; reset1 = 1'b0;

        // Both high -> both outputs high
        @(posedge clk); #1; set1 = 1'b1; reset1 = 1'b1;
        @(posedge clk); #1;
        check(q1, 1'b1, "set1&reset1 -> q1=1");
        check(q1_n, 1'b1, "set1&reset1 -> q1_n=1");
        @(posedge clk); #1; set1 = 1'b0; reset1 = 1'b0;

        // Re-clock FF1 to a known 0 before testing FF2 independence
        tick1(1'b0);
        check(q1, 1'b0, "FF1 back to 0");

        // FF2 independent: clock D2=1 while FF1 stays put
        @(posedge clk); #1; d2 = 1'b1; clk2 = 1'b0;
        @(posedge clk); #1; clk2 = 1'b1;
        @(posedge clk); #1;
        check(q2, 1'b1, "FF2 clock D2=1 -> q2=1");
        check(q1, 1'b0, "FF1 unaffected by FF2 clock");

        if (error_count == 0) begin
            $display("PASS: tb_cd4013"); $finish;
        end else begin
            $display("FAIL: tb_cd4013 (%0d errors)", error_count); $fatal(1);
        end
    end
endmodule : tb_cd4013
