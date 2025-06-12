/*
 * @file gprf_tb.v
 * @brief Testbench for the General Purpose Register File (GPRF) module.
 */

`timescale 1ns / 1ps
module gprf_tb;
    parameter CLK_PERIOD = 10;
    parameter MAX_TESTS = 100;

    reg clk;
    reg rst;
    reg [4:0] address_A;
    reg [4:0] address_B;
    reg [4:0] address_W;
    reg [31:0] write_data;
    reg write_enable;
    wire [31:0] reg_A;
    wire [31:0] reg_B;

    integer file_handle;
    integer scan_result;
    integer test_count;
    integer error_count;
    reg [31:0] expected_reg_A;
    reg [31:0] expected_reg_B;
    reg [200*8-1:0] line_buffer;

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

    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    initial begin
        $dumpfile("build/gprf_tb.vcd");
        $dumpvars(0, gprf_tb);
        test_count = 0;
        error_count = 0;
        rst = 1;
        address_A = 0;
        address_B = 0;
        address_W = 0;
        write_data = 0;
        write_enable = 0;

        repeat(5) @(posedge clk);
        rst = 0;
        @(posedge clk);

        file_handle = $fopen("sim/stimuli/gprf_ports.csv", "r");
        if (file_handle == 0) begin
            $display("ERROR: Could not open gprf_ports.csv file");
            $finish;
        end

        $display("Starting GPRF testbench with CSV stimuli...");

        while (!$feof(file_handle) && test_count < MAX_TESTS) begin
            scan_result = $fgets(line_buffer, file_handle);
            if (scan_result && line_buffer[0] != "#" && line_buffer[0] != "\n") begin
                scan_result = $sscanf(line_buffer, "%d,%d,%d,%d,%d,%d,%d,%d",
                    rst, address_A, address_B, address_W, write_data, write_enable,
                    expected_reg_A, expected_reg_B);

                if (scan_result == 8) begin
                    @(posedge clk);
                    #1;
                    if (reg_A !== expected_reg_A) begin
                        $display("FAIL [%0d] GPRF reg_A\n  addr_A=%2d  addr_B=%2d  addr_W=%2d  wdata=0x%08h  wen=%b\n  reg_A:    0x%08h\n  Expected: 0x%08h",
                            test_count, address_A, address_B, address_W, write_data, write_enable, reg_A, expected_reg_A);
                        error_count = error_count + 1;
                    end
                    if (reg_B !== expected_reg_B) begin
                        $display("FAIL [%0d] GPRF reg_B\n  addr_A=%2d  addr_B=%2d  addr_W=%2d  wdata=0x%08h  wen=%b\n  reg_B:    0x%08h\n  Expected: 0x%08h",
                            test_count, address_A, address_B, address_W, write_data, write_enable, reg_B, expected_reg_B);
                        error_count = error_count + 1;
                    end
                    if (reg_A === expected_reg_A && reg_B === expected_reg_B) begin
                        $display("PASS [%0d] GPRF  addr_A=%2d  addr_B=%2d  addr_W=%2d  wdata=0x%08h  wen=%b  reg_A=0x%08h  reg_B=0x%08h",
                            test_count, address_A, address_B, address_W, write_data, write_enable, reg_A, reg_B);
                    end
                    test_count = test_count + 1;
                end
            end
        end

        $fclose(file_handle);
        $display("\n=== Test Summary ===");
        $display("Total tests:   %0d", test_count);
        $display("Failed tests:  %0d", error_count);
        $display("Passed tests:  %0d", test_count - error_count);

        if (error_count == 0 && test_count > 0) begin
            $display("All tests PASSED!");
        end else if (test_count == 0) begin
            $display("No test vectors found or processed from CSV.");
        end else begin
            $display("Some tests FAILED!");
        end

        $finish;
    end

endmodule