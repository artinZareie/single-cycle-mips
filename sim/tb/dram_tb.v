/*
 * @file dram_tb.v
 * @brief Testbench for the DRAM module.
 */

`timescale 1ns / 1ps
module dram_tb;
    parameter CLK_PERIOD = 10;
    parameter ADDR_WIDTH = 4;  // 4 bits for 16 addresses (for testbench)
    parameter DATA_WIDTH = 8;
    parameter ROWS = 1;
    parameter COLS = 16;
    parameter MAX_TESTS = 100;

    reg clk;
    reg rst;
    reg [ADDR_WIDTH-1:0] addr;
    reg [DATA_WIDTH-1:0] wdata;
    reg write_enable;
    wire [DATA_WIDTH-1:0] rdata;

    integer file_handle;
    integer scan_result;
    integer test_count;
    integer error_count;
    reg [DATA_WIDTH-1:0] expected_rdata;
    reg [200*8-1:0] line_buffer;
    integer rst_csv;
    integer wdata_csv;
    integer write_enable_csv;
    integer addr_csv;

    // Instantiate DRAM with small size for simulation
    DRAM #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .ROWS(ROWS),
        .COLS(COLS)
    ) uut (
        .clk(clk),
        .rst(rst),
        .addr(addr),
        .wdata(wdata),
        .write_enable(write_enable),
        .rdata(rdata)
    );

    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    initial begin
        $dumpfile("build/dram_tb.vcd");
        $dumpvars(0, dram_tb);
        test_count = 0;
        error_count = 0;
        rst = 1;
        addr = 0;
        wdata = 0;
        write_enable = 0;

        repeat (3) @(posedge clk);
        rst = 0;
        @(posedge clk);

        file_handle = $fopen("sim/stimuli/dram_ports.csv", "r");
        if (file_handle == 0) begin
            $display("ERROR: Could not open dram_ports.csv file");
            $finish;
        end

        $display("Starting DRAM testbench with CSV stimuli...");

        while (!$feof(
            file_handle
        ) && test_count < MAX_TESTS) begin
            scan_result = $fgets(line_buffer, file_handle);
            if (scan_result && line_buffer[0] != "#" && line_buffer[0] != "\n") begin
                scan_result = $sscanf(
                    line_buffer,
                    "%d,%d,%d,%d,%d",
                    rst_csv,
                    addr_csv,
                    wdata_csv,
                    write_enable_csv,
                    expected_rdata
                );
                if (scan_result == 5) begin
                    rst = rst_csv;
                    addr = addr_csv[ADDR_WIDTH-1:0];
                    wdata = wdata_csv[DATA_WIDTH-1:0];
                    write_enable = write_enable_csv;
                    if (write_enable) begin
                        @(negedge clk);
                    end else begin
                        @(posedge clk);
                    end
                    #1;
                    if (rdata !== expected_rdata) begin
                        $display(
                            "FAIL [%0d] DRAM addr=%2d wdata=0x%02h wen=%b rst=%b  rdata=0x%02h  Expected=0x%02h",
                            test_count, addr, wdata, write_enable, rst, rdata, expected_rdata);
                        error_count = error_count + 1;
                    end else begin
                        $display(
                            "PASS [%0d] DRAM addr=%2d wdata=0x%02h wen=%b rst=%b  rdata=0x%02h",
                            test_count, addr, wdata, write_enable, rst, rdata);
                    end
                    test_count = test_count + 1;
                end
            end
        end

        $fclose(file_handle);
        $display("\n=== DRAM Test Summary ===");
        $display("Total tests:   %0d", test_count);
        $display("Failed tests:  %0d", error_count);
        $display("Passed tests:  %0d", test_count - error_count);

        if (error_count == 0 && test_count > 0) begin
            $display("All DRAM tests PASSED!");
        end else if (test_count == 0) begin
            $display("No test vectors found or processed from CSV.");
        end else begin
            $display("Some DRAM tests FAILED!");
        end

        $finish;
    end
endmodule
