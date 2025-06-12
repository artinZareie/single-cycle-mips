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
        forever #(CLK_PERIOD / 2) clk = ~clk; // Toggle clock.
    end

    // Test sequence
    initial begin
        // Generate VCD file for visualization
        $dumpfile("build/gprf_tb.vcd");
        $dumpvars(0, gprf_tb);
        
        // Initialize variables
        test_count = 0;
        error_count = 0;
        
        // Initialize inputs
        rst = 1;  // Start with reset active
        address_A = 5'b00000;
        address_B = 5'b00000;
        address_W = 5'b00000;
        write_data = 32'h00000000;
        write_enable = 0;

        $display("Applying reset sequence...");
        
        // Hold reset for several clock cycles to ensure proper initialization
        repeat(5) @(posedge clk);
        
        // Check if registers are zero during reset
        #1;
        $display("During reset - reg_A (addr 1): %h, reg_B (addr 2): %h", reg_A, reg_B);
        address_A = 1; address_B = 2; // Check some non-zero registers
        #1;
        $display("During reset - reg_A (addr 1): %h, reg_B (addr 2): %h", reg_A, reg_B);
        address_A = 31; address_B = 5; // Check more registers
        #1;
        $display("During reset - reg_A (addr 31): %h, reg_B (addr 5): %h", reg_A, reg_B);
        
        rst = 0;  // Release reset
        $display("Reset released, starting tests...");
        @(posedge clk);  // Wait one more cycle after reset release
        
        // Debug: Check register state immediately after reset
        address_A = 1; address_B = 2;
        #1;
        $display("After reset release - reg_A (addr 1): %h, reg_B (addr 2): %h", reg_A, reg_B);
        address_A = 31; address_B = 5;
        #1;
        $display("After reset release - reg_A (addr 31): %h, reg_B (addr 5): %h", reg_A, reg_B);
        
        // Reset addresses for testing
        address_A = 5'b00000;
        address_B = 5'b00000;

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
                    
                    // Debug: Show actual register file contents for failing tests
                    if (reg_A !== expected_reg_A || reg_B !== expected_reg_B) begin
                        $display("DEBUG Test %0d: Inputs applied - rst=%b, addr_A=%d, addr_B=%d, addr_W=%d, write_data=%h, write_en=%b", 
                                test_count, rst, address_A, address_B, address_W, write_data, write_enable);
                        $display("DEBUG Test %0d: Internal register check - gpregs[%d]=%h, gpregs[%d]=%h", 
                                test_count, address_A, uut.gpregs[address_A], address_B, uut.gpregs[address_B]);
                    end
                    
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
                        $display("Test %0d PASSED: rst=%b, addr_A=%d, addr_B=%d, addr_W=%d, write_data=%h, write_en=%b", 
                                test_count, rst, address_A, address_B, address_W, write_data, write_enable);
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

    // Monitor changes (optional - can be disabled for cleaner output)
    // initial begin
    //     $monitor("Time: %0t | reg_A: %h | reg_B: %h | address_A: %b | address_B: %b | address_W: %b | write_data: %h | write_enable: %b",
    //              $time, reg_A, reg_B, address_A, address_B, address_W, write_data, write_enable);
    // end
endmodule