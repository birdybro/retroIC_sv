// tb_cd4040 — self-checking testbench for the 12-stage counter.
// Covers: reset, falling-edge counting, low-stage wrap, master reset.
// Convention: stimulus changes 1ns after a posedge to avoid clock/data races.
// Run under: verilator --binary --timing
`timescale 1ns/1ps
module tb_cd4040;

    int error_count = 0;
    task automatic check(input logic [63:0] got, expected, input string label);
        if (got !== expected) begin
            $display("FAIL: %s got=%h exp=%h", label, got, expected);
            error_count++;
        end
    endtask

    logic clk = 1'b0;
    always #5 clk = ~clk;

    localparam int STAGES = 12;
    logic               reset_n;
    logic               clk_in, master_reset;
    logic [STAGES-1:0]  q;

    cd4040 #(.STAGES(STAGES)) dut (
        .clk(clk), .reset_n(reset_n), .clk_in(clk_in),
        .master_reset(master_reset), .q(q)
    );

    // One count: a high-then-low transition produces a falling edge.
    task automatic tick();
        @(posedge clk); #1; clk_in = 1'b1;
        @(posedge clk); #1; clk_in = 1'b0;   // falling edge presented
        @(posedge clk); #1;                   // counted at this edge
    endtask

    initial begin
        reset_n = 1'b0; clk_in = 1'b0; master_reset = 1'b0;
        @(posedge clk); #1;
        check(q, '0, "reset clears counter");
        @(posedge clk); #1; reset_n = 1'b1;

        // Count up to 5
        for (int i = 1; i <= 5; i++) begin
            tick();
            check(q, i[STAGES-1:0], $sformatf("count after %0d ticks", i));
        end

        // Master reset clears
        @(posedge clk); #1; master_reset = 1'b1;
        @(posedge clk); #1; master_reset = 1'b0;
        check(q, '0, "master_reset clears");

        // Low-stage wrap: Q1 toggles every tick, Q2 sets after two ticks
        tick(); check(q[0], 1'b1, "Q1 set after 1 tick");
        tick(); check(q[0], 1'b0, "Q1 clear after 2 ticks (stage-1 wrap)");
        check(q[1], 1'b1, "Q2 set after 2 ticks");

        if (error_count == 0) begin
            $display("PASS: tb_cd4040"); $finish;
        end else begin
            $display("FAIL: tb_cd4040 (%0d errors)", error_count); $fatal(1);
        end
    end
endmodule : tb_cd4040
