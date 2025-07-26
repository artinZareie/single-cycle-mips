/*
 * @file imem_tb.v
 * @brief Minimal testbench for the Instruction Memory module.
 */

`timescale 1ns / 1ps
module imem_tb;

    parameter CLK_PERIOD = 10;

    reg [31:0] addr;
    reg clk;
    wire [31:0] rdata;

    InstMem uut (
        .addr (addr),
        .clk  (clk),
        .rdata(rdata)
    );

    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    initial begin
        $dumpfile("build/imem_tb.vcd");
        $dumpvars(0, imem_tb);

        $display("Starting Instruction Memory wrapper test");

        addr = 32'h00000000;
        #(CLK_PERIOD * 2);
        $display("Addr: 0x%08h, RData: 0x%08h", addr, rdata);

        addr = 32'h00000004;
        #(CLK_PERIOD);
        $display("Addr: 0x%08h, RData: 0x%08h", addr, rdata);

        addr = 32'h00000008;
        #(CLK_PERIOD);
        $display("Addr: 0x%08h, RData: 0x%08h", addr, rdata);

        $display("InstMem wrapper test completed");
        $finish;
    end

endmodule
