/*
 * @file mux41_tb.v
 * @brief Testbench for the Mux41 module.
 */

`timescale 1ns / 1ps
module mux41_tb;

    parameter CLK_PERIOD = 10;

    reg clk;
    reg [31:0] a_tb;
    reg [31:0] b_tb;
    reg [31:0] c_tb;
    reg [31:0] d_tb;
    reg [1:0] sel_tb;
    wire [31:0] out_tb;

    integer test_count;
    integer error_count;
    reg [31:0] expected;

    Mux41 uut (
        .a(a_tb),
        .b(b_tb),
        .c(c_tb),
        .d(d_tb),
        .sel(sel_tb),
        .out(out_tb)
    );

    initial begin
        clk = 0;
        repeat (20) @(posedge clk);
    end
    always #(CLK_PERIOD / 2) clk = ~clk;

    initial begin
        $dumpfile("build/mux41_tb.vcd");
        $dumpvars(0, mux41_tb);
        
        test_count = 0;
        error_count = 0;
        a_tb = 32'h11111111;
        b_tb = 32'h22222222;
        c_tb = 32'h33333333;
        d_tb = 32'h44444444;
        sel_tb = 2'b00;
        
        #(CLK_PERIOD);
        
        $display("Starting Mux41 testbench...");
        $display("Test# | A        | B        | C        | D        | Sel | Out      | Expected | Status");
        $display("------|----------|----------|----------|----------|-----|----------|----------|-------");

        sel_tb = 2'b00;
        expected = a_tb;
        #1;
        test_count = test_count + 1;
        if (out_tb == expected) begin
            $display("[%0d]  | %08h | %08h | %08h | %08h | %2b  | %08h | %08h | PASS", 
                test_count, a_tb, b_tb, c_tb, d_tb, sel_tb, out_tb, expected);
        end else begin
            $display("[%0d]  | %08h | %08h | %08h | %08h | %2b  | %08h | %08h | FAIL", 
                test_count, a_tb, b_tb, c_tb, d_tb, sel_tb, out_tb, expected);
            error_count = error_count + 1;
        end

        sel_tb = 2'b01;
        expected = b_tb;
        #1;
        test_count = test_count + 1;
        if (out_tb == expected) begin
            $display("[%0d]  | %08h | %08h | %08h | %08h | %2b  | %08h | %08h | PASS", 
                test_count, a_tb, b_tb, c_tb, d_tb, sel_tb, out_tb, expected);
        end else begin
            $display("[%0d]  | %08h | %08h | %08h | %08h | %2b  | %08h | %08h | FAIL", 
                test_count, a_tb, b_tb, c_tb, d_tb, sel_tb, out_tb, expected);
            error_count = error_count + 1;
        end

        sel_tb = 2'b10;
        expected = c_tb;
        #1;
        test_count = test_count + 1;
        if (out_tb == expected) begin
            $display("[%0d]  | %08h | %08h | %08h | %08h | %2b  | %08h | %08h | PASS", 
                test_count, a_tb, b_tb, c_tb, d_tb, sel_tb, out_tb, expected);
        end else begin
            $display("[%0d]  | %08h | %08h | %08h | %08h | %2b  | %08h | %08h | FAIL", 
                test_count, a_tb, b_tb, c_tb, d_tb, sel_tb, out_tb, expected);
            error_count = error_count + 1;
        end

        sel_tb = 2'b11;
        expected = d_tb;
        #1;
        test_count = test_count + 1;
        if (out_tb == expected) begin
            $display("[%0d]  | %08h | %08h | %08h | %08h | %2b  | %08h | %08h | PASS", 
                test_count, a_tb, b_tb, c_tb, d_tb, sel_tb, out_tb, expected);
        end else begin
            $display("[%0d]  | %08h | %08h | %08h | %08h | %2b  | %08h | %08h | FAIL", 
                test_count, a_tb, b_tb, c_tb, d_tb, sel_tb, out_tb, expected);
            error_count = error_count + 1;
        end

        a_tb = 32'h00000000;
        b_tb = 32'hFFFFFFFF;
        c_tb = 32'h55555555;
        d_tb = 32'hAAAAAAAA;
        
        sel_tb = 2'b00;
        expected = a_tb;
        #1;
        test_count = test_count + 1;
        if (out_tb == expected) begin
            $display("[%0d]  | %08h | %08h | %08h | %08h | %2b  | %08h | %08h | PASS", 
                test_count, a_tb, b_tb, c_tb, d_tb, sel_tb, out_tb, expected);
        end else begin
            $display("[%0d]  | %08h | %08h | %08h | %08h | %2b  | %08h | %08h | FAIL", 
                test_count, a_tb, b_tb, c_tb, d_tb, sel_tb, out_tb, expected);
            error_count = error_count + 1;
        end

        sel_tb = 2'b11;
        expected = d_tb;
        #1;
        test_count = test_count + 1;
        if (out_tb == expected) begin
            $display("[%0d]  | %08h | %08h | %08h | %08h | %2b  | %08h | %08h | PASS", 
                test_count, a_tb, b_tb, c_tb, d_tb, sel_tb, out_tb, expected);
        end else begin
            $display("[%0d]  | %08h | %08h | %08h | %08h | %2b  | %08h | %08h | FAIL", 
                test_count, a_tb, b_tb, c_tb, d_tb, sel_tb, out_tb, expected);
            error_count = error_count + 1;
        end

        // Display summary
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
