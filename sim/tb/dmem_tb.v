/*
 * @file dmem_tb.v
 * @brief Minimal testbench for the Data Memory module.
 */

`timescale 1ns / 1ps
module dmem_tb;

    parameter CLK_PERIOD = 10;

    reg [31:0] addr;
    reg clk;
    reg we;
    reg [31:0] wdata;
    wire [31:0] rdata;

    DataMem uut (
        .addr(addr),
        .clk(clk),
        .we(we),
        .wdata(wdata),
        .rdata(rdata)
    );

    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    initial begin
        $dumpfile("build/dmem_tb.vcd");
        $dumpvars(0, dmem_tb);

        $display("Starting Data Memory wrapper test");

        addr = 32'h00000000;
        we = 1'b0;
        wdata = 32'h00000000;
        #(CLK_PERIOD);

        we = 1'b1;
        addr = 32'h00000000;
        wdata = 32'hDEADBEEF;
        #(CLK_PERIOD);
        $display("Write: Addr=0x%08h, WData=0x%08h", addr, wdata);

        we = 1'b0;
        #(CLK_PERIOD);
        $display("Read:  Addr=0x%08h, RData=0x%08h", addr, rdata);

        we = 1'b1;
        addr = 32'h00000004;
        wdata = 32'hCAFEBABE;
        #(CLK_PERIOD);

        we = 1'b0;
        #(CLK_PERIOD);
        $display("Read:  Addr=0x%08h, RData=0x%08h", addr, rdata);

        $display("DataMem wrapper test completed");
        $finish;
    end

endmodule
