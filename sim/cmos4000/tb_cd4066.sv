// tb_cd4066 — self-checking testbench for the quad bilateral switch model.
// Covers: pass when control high, open (output 0, oe 0) when control low,
// per-switch independence.
// Run under: verilator --binary --timing
`timescale 1ns/1ps
module tb_cd4066;

    int error_count = 0;
    task automatic check(input logic [63:0] got, expected, input string label);
        if (got !== expected) begin
            $display("FAIL: %s got=%h exp=%h", label, got, expected);
            error_count++;
        end
    endtask

    logic [3:0] a;
    logic [3:0] control;
    logic [3:0] y;
    logic [3:0] y_oe;

    cd4066 dut (.a(a), .control(control), .y(y), .y_oe(y_oe));

    initial begin
        // All closed: y follows a, oe all high
        a = 4'b1011; control = 4'b1111; #1;
        check(y, 4'b1011, "all closed: y=a");
        check(y_oe, 4'b1111, "all closed: oe=1");

        // All open: y=0, oe=0
        control = 4'b0000; #1;
        check(y, 4'b0000, "all open: y=0");
        check(y_oe, 4'b0000, "all open: oe=0");

        // Mixed: switches 0 and 2 closed, 1 and 3 open
        a = 4'b1111; control = 4'b0101; #1;
        check(y,    4'b0101, "mixed: only closed switches pass");
        check(y_oe, 4'b0101, "mixed: oe matches control");

        // Independence: change a on open switch has no effect
        a = 4'b1010; #1;     // switch1 (open) input changes
        check(y, 4'b0000, "open switch input change ignored");
        // switch0 open now too since a[0]=0; switch2 closed, a[2]=0 -> y[2]=0
        check(y[2], 1'b0, "closed switch passes new a[2]=0");

        if (error_count == 0) begin
            $display("PASS: tb_cd4066"); $finish;
        end else begin
            $display("FAIL: tb_cd4066 (%0d errors)", error_count); $fatal(1);
        end
    end
endmodule : tb_cd4066
