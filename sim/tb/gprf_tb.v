/*
 * @file gprf_tb.v
 * @brief Testbench for the General Purpose Register File (GPRF) module.
 * @author Artin Zarei | Mohsen Mirzaei
 */

`timescale 1ns / 1ps
module gprf_tb;

    // Parameters
    parameter CLK_PERIOD = 10; // Clock period in nanoseconds

    // Inputs
    reg clk;
    reg rst;
    reg [4:0] address_A;
    reg [4:0] address_B;
    reg [4:0] address_W;
    reg [31:0] write_data;
    reg write_enable;

    // Outputs
    wire [31:0] reg_A;
    wire [31:0] reg_B;

    // Instantiate the RegisterFile module
    RegisterFile uut (
        .clk(clk),
        .rst(rst),
        .address_A(address_A),
        .address_B(address_B),
        .address_W(address_W),
        .write_data(write_data),
        .write_enable(write_enable),
        .reg_A(reg_A),
        .reg_B(reg_B)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk; // Toggle clock.
    end

    // Test sequence
    initial begin
        // Generate VCD file for visualization
        $dumpfile("build/gprf_tb.vcd");
        $dumpvars(0, gprf_tb);
        
        // Initialize inputs
        rst = 1;
        address_A = 5'b00000;
        address_B = 5'b00001;
        address_W = 5'b00001;
        write_data = 32'h12345678;
        write_enable = 0;

        // Wait for a few clock cycles
        #20;

        // Release reset
        rst = 0;

        // Write data to register $1
        write_enable = 1;
        #CLK_PERIOD;

        // Disable write enable and read from registers
        write_enable = 0;
        
        // Read from registers after writing to $1
        #CLK_PERIOD;

        // Check outputs
        if (reg_A !== 32'b0) begin
            $display("Test failed: Expected reg_A to be 0, got %h", reg_A);
            $finish;
        end
        
        if (reg_B !== 32'h12345678) begin
            $display("Test failed: Expected reg_B to be 12345678, got %h", reg_B);
            $finish;
        end
        
        $display("Test passed: Register file works correctly.");
        $finish;
    end

    // Monitor changes
    initial begin
        $monitor("Time: %0t | reg_A: %h | reg_B: %h | address_A: %b | address_B: %b | address_W: %b | write_data: %h | write_enable: %b",
                 $time, reg_A, reg_B, address_A, address_B, address_W, write_data, write_enable);
    end
endmodule