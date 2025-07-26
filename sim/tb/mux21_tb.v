/*
 * @file mux21_tb.v
 * @brief Testbench for the Mux21 module.
 */

`timescale 1ns / 1ps
module mux21_tb;

    parameter CLK_PERIOD = 10;

    reg clk;
    reg [31:0] a_tb;
    reg [31:0] b_tb;
    reg sel_tb;
    wire [31:0] out_tb;

    integer test_count;
    integer error_count;

    Mux21 uut (
        .a  (a_tb),
        .b  (b_tb),
        .sel(sel_tb),
        .out(out_tb)
    );

    initial begin
        clk = 0;
        repeat (20) @(posedge clk);
    end
    always #(CLK_PERIOD / 2) clk = ~clk;

    initial begin
        $dumpfile("build/mux21_tb.vcd");
        $dumpvars(0, mux21_tb);

        test_count = 0;
        error_count = 0;
        a_tb = 0;
        b_tb = 0;
        sel_tb = 0;

        #(CLK_PERIOD);

        $display("Starting Mux21 testbench...");
        $display("Test# | A        | B        | Sel | Out      | Expected | Status");
        $display("------|----------|----------|-----|----------|----------|-------");

        a_tb   = 32'h12345678;
        b_tb   = 32'hABCDEF00;
        sel_tb = 1'b0;
        #1;
        test_count = test_count + 1;
        if (out_tb == a_tb) begin
            $display("[%0d]  | %08h | %08h |  %b  | %08h | %08h | PASS", test_count, a_tb, b_tb,
                     sel_tb, out_tb, a_tb);
        end else begin
            $display("[%0d]  | %08h | %08h |  %b  | %08h | %08h | FAIL", test_count, a_tb, b_tb,
                     sel_tb, out_tb, a_tb);
            error_count = error_count + 1;
        end

        a_tb   = 32'h11111111;
        b_tb   = 32'h22222222;
        sel_tb = 1'b1;
        #1;
        test_count = test_count + 1;
        if (out_tb == b_tb) begin
            $display("[%0d]  | %08h | %08h |  %b  | %08h | %08h | PASS", test_count, a_tb, b_tb,
                     sel_tb, out_tb, b_tb);
        end else begin
            $display("[%0d]  | %08h | %08h |  %b  | %08h | %08h | FAIL", test_count, a_tb, b_tb,
                     sel_tb, out_tb, b_tb);
            error_count = error_count + 1;
        end

        a_tb   = 32'h00000000;
        b_tb   = 32'hFFFFFFFF;
        sel_tb = 1'b0;
        #1;
        test_count = test_count + 1;
        if (out_tb == a_tb) begin
            $display("[%0d]  | %08h | %08h |  %b  | %08h | %08h | PASS", test_count, a_tb, b_tb,
                     sel_tb, out_tb, a_tb);
        end else begin
            $display("[%0d]  | %08h | %08h |  %b  | %08h | %08h | FAIL", test_count, a_tb, b_tb,
                     sel_tb, out_tb, a_tb);
            error_count = error_count + 1;
        end

        a_tb   = 32'hFFFFFFFF;
        b_tb   = 32'h00000000;
        sel_tb = 1'b1;
        #1;
        test_count = test_count + 1;
        if (out_tb == b_tb) begin
            $display("[%0d]  | %08h | %08h |  %b  | %08h | %08h | PASS", test_count, a_tb, b_tb,
                     sel_tb, out_tb, b_tb);
        end else begin
            $display("[%0d]  | %08h | %08h |  %b  | %08h | %08h | FAIL", test_count, a_tb, b_tb,
                     sel_tb, out_tb, b_tb);
            error_count = error_count + 1;
        end

        $display("\n=== Test Summary ===");
        $display("Total tests:   %0d", test_count);
        $display("Failed tests:  %0d", error_count);
        $display("Passed tests:  %0d", test_count - error_count);

        if (error_count == 0) begin
            $display("All tests PASSED!");
        end else begin
            $display("Some tests FAILED!");
        end

        $finish;
    end

endmodule
