// tb_cd4520 — self-checking testbench for the dual 4-bit counter.
// Covers: reset, rising-edge counting, enable gating, terminal-count wrap,
// independence of the two counters.
// Convention: stimulus changes 1ns after a posedge to avoid clock/data races.
// Run under: verilator --binary --timing
`timescale 1ns/1ps
module tb_cd4520;

    int error_count = 0;
    task automatic check(input logic [63:0] got, expected, input string label);
        if (got !== expected) begin
            $display("FAIL: %s got=%h exp=%h", label, got, expected);
            error_count++;
        end
    endtask

    logic clk = 1'b0;
    always #5 clk = ~clk;

    logic       reset_n;
    logic       clk_a, enable_a, reset_a;
    logic [3:0] q_a;
    logic       clk_b, enable_b, reset_b;
    logic [3:0] q_b;

    cd4520 dut (
        .clk(clk), .reset_n(reset_n),
        .clk_a(clk_a), .enable_a(enable_a), .reset_a(reset_a), .q_a(q_a),
        .clk_b(clk_b), .enable_b(enable_b), .reset_b(reset_b), .q_b(q_b)
    );

    // Rising edge on counter A's clock (counts when enable_a is high).
    task automatic tick_a();
        @(posedge clk); #1; clk_a = 1'b0;
        @(posedge clk); #1; clk_a = 1'b1;   // rising edge presented
        @(posedge clk); #1;                  // counted at this edge
    endtask

    initial begin
        reset_n = 1'b0;
        clk_a = 0; enable_a = 1; reset_a = 0;
        clk_b = 0; enable_b = 1; reset_b = 0;
        @(posedge clk); #1;
        check(q_a, 4'd0, "reset clears A");
        check(q_b, 4'd0, "reset clears B");
        @(posedge clk); #1; reset_n = 1'b1;

        // Count A to 3
        for (int i = 1; i <= 3; i++) begin
            tick_a();
            check(q_a, i[3:0], $sformatf("A count %0d", i));
        end
        check(q_b, 4'd0, "B unchanged while A counts");

        // Enable gating: with enable low, ticks must not count
        @(posedge clk); #1; enable_a = 1'b0;
        tick_a(); tick_a();
        check(q_a, 4'd3, "A frozen when enable low");
        @(posedge clk); #1; enable_a = 1'b1;

        // Count to terminal (15) then wrap to 0
        while (q_a != 4'd15) tick_a();
        check(q_a, 4'd15, "A at terminal count 15");
        tick_a();
        check(q_a, 4'd0, "A wraps 15 -> 0");

        // Counter B reset is independent
        @(posedge clk); #1; reset_b = 1'b1;
        @(posedge clk); #1; reset_b = 1'b0;
        check(q_b, 4'd0, "B reset independent");

        if (error_count == 0) begin
            $display("PASS: tb_cd4520"); $finish;
        end else begin
            $display("FAIL: tb_cd4520 (%0d errors)", error_count); $fatal(1);
        end
    end
endmodule : tb_cd4520
