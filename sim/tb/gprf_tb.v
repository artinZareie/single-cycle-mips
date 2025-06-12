/*
 * @file gprf_tb.v
 * @brief Testbench for the General Purpose Register File (GPRF) module.
 * @author Artin Zarei | Mohsen Mirzaei
 */

`timescale 1ns / 1ps
module gprf_tb;

    // Parameters
    parameter CLK_PERIOD = 10; // Clock period in nanoseconds
    parameter MAX_TESTS = 100; // Maximum number of test cases

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

    // Test variables
    integer file_handle;
    integer scan_result;
    integer test_count;
    integer error_count;
    reg [31:0] expected_reg_A;
    reg [31:0] expected_reg_B;
    reg [200*8-1:0] line_buffer; // Buffer for reading lines

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
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // Test sequence
    initial begin
        // Generate VCD file for visualization
        $dumpfile("build/gprf_tb.vcd");
        $dumpvars(0, gprf_tb);
        
        // Initialize variables
        test_count = 0;
        error_count = 0;
        
        // Initialize inputs and apply reset
        rst = 1;
        address_A = 5'b00000;
        address_B = 5'b00000;
        address_W = 5'b00000;
        write_data = 32'h00000000;
        write_enable = 0;

        // Hold reset for several clock cycles
        repeat(5) @(posedge clk);
        rst = 0;
        @(posedge clk);

        // Open CSV file
        file_handle = $fopen("sim/stimuli/gprf_ports.csv", "r");
        if (file_handle == 0) begin
            $display("ERROR: Could not open gprf_ports.csv file");
            $finish;
        end

        $display("Starting GPRF testbench with CSV stimuli...");

        // Read and process each line from CSV
        while (!$feof(file_handle) && test_count < MAX_TESTS) begin
            scan_result = $fgets(line_buffer, file_handle);
            
            // Skip empty lines and comments
            if (scan_result && line_buffer[0] != "#" && line_buffer[0] != "\n") begin
                // Parse CSV line: rst,address_A,address_B,address_W,write_data,write_enable,expected_reg_A,expected_reg_B
                scan_result = $sscanf(line_buffer, "%d,%d,%d,%d,%d,%d,%d,%d",
                                    rst, address_A, address_B, address_W, write_data, write_enable,
                                    expected_reg_A, expected_reg_B);
                
                if (scan_result == 8) begin
                    // Apply inputs at positive clock edge
                    @(posedge clk);
                    
                    // Wait for combinational logic to settle
                    #1;
                    
                    // Check outputs against expected values
                    if (reg_A !== expected_reg_A) begin
                        $display("Test %0d FAILED: reg_A mismatch - Expected: %h, Got: %h (addr_A=%d)", 
                                test_count, expected_reg_A, reg_A, address_A);
                        error_count = error_count + 1;
                    end
                    
                    if (reg_B !== expected_reg_B) begin
                        $display("Test %0d FAILED: reg_B mismatch - Expected: %h, Got: %h (addr_B=%d)", 
                                test_count, expected_reg_B, reg_B, address_B);
                        error_count = error_count + 1;
                    end
                    
                    if (reg_A === expected_reg_A && reg_B === expected_reg_B) begin
                        $display("Test %0d PASSED: addr_A=%d, addr_B=%d, addr_W=%d, write_data=%h, write_en=%b", 
                                test_count, address_A, address_B, address_W, write_data, write_enable);
                    end
                    
                    test_count = test_count + 1;
                end
            end
        end

        // Close file and report results
        $fclose(file_handle);
        
        $display("\n=== Test Summary ===");
        $display("Total tests: %0d", test_count);
        $display("Failed tests: %0d", error_count);
        $display("Passed tests: %0d", test_count - error_count);
        
        if (error_count == 0) begin
            $display("All tests PASSED!");
        end else begin
            $display("Some tests FAILED!");
        end
        
        $finish;
    end

endmodule