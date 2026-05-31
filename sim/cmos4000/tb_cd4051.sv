// tb_cd4051 — self-checking testbench for the 8:1 mux / 1:8 demux model.
// Covers: mux channel selection truth table, demux one-hot routing, inhibit.
// Run under: verilator --binary --timing
`timescale 1ns/1ps
module tb_cd4051;

    int error_count = 0;
    task automatic check(input logic [63:0] got, expected, input string label);
        if (got !== expected) begin
            $display("FAIL: %s got=%h exp=%h", label, got, expected);
            error_count++;
        end
    endtask

    logic [2:0] select;
    logic       inhibit;
    logic [7:0] channel_in;
    logic       common_out;
    logic       common_in;
    logic [7:0] channel_out;

    cd4051 dut (
        .select(select), .inhibit(inhibit),
        .channel_in(channel_in), .common_out(common_out),
        .common_in(common_in), .channel_out(channel_out)
    );

    initial begin
        // Mux: channel_in = 1010_1100, walk the select across all 8 channels.
        channel_in = 8'b1010_1100;
        common_in  = 1'b0;
        inhibit    = 1'b0;
        for (int s = 0; s < 8; s++) begin
            select = s[2:0]; #1;
            check(common_out, channel_in[s], $sformatf("mux sel=%0d", s));
        end

        // Inhibit forces common_out low
        select = 3'd2; inhibit = 1'b1; #1;   // channel 2 would be 1
        check(common_out, 1'b0, "inhibit forces common_out=0");
        inhibit = 1'b0;

        // Demux: drive common_in high, selected channel is one-hot
        common_in = 1'b1;
        for (int s = 0; s < 8; s++) begin
            select = s[2:0]; #1;
            check(channel_out, (8'b1 << s), $sformatf("demux sel=%0d one-hot", s));
        end

        // Inhibit forces all channel outputs low
        select = 3'd5; inhibit = 1'b1; #1;
        check(channel_out, 8'h00, "inhibit forces channel_out=0");

        if (error_count == 0) begin
            $display("PASS: tb_cd4051"); $finish;
        end else begin
            $display("FAIL: tb_cd4051 (%0d errors)", error_count); $fatal(1);
        end
    end
endmodule : tb_cd4051
