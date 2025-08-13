`timescale 1ns/1ps

/**
 * @file tb_InnerProduct.v
 * @brief Testbench for dot product calculation using MIPS CPU
 * @details Tests the dot product of two 4-element vectors:
 *          Vector A = [1, 2, 3, 4] at word addresses 0-3
 *          Vector B = [5, 6, 7, 8] at word addresses 4-7
 *          Expected result: 1*5 + 2*6 + 3*7 + 4*8 = 5 + 12 + 21 + 32 = 70
 */

module tb_InnerProduct();

    // Clock and reset signals
    reg clk = 0;
    reg reset = 1;
    
    // Debug signals from CPU
    wire [31:0] debug_pc;
    wire [31:0] debug_instruction;
    wire [31:0] debug_alu_result;
    wire [31:0] debug_mem_data;
    
    // Test parameters
    parameter CLOCK_PERIOD = 10;  // 100MHz clock
    parameter MAX_CYCLES = 200;   // Maximum simulation cycles
    
    // Expected test vectors (using individual parameters instead of arrays)
    parameter [31:0] VECTOR_A_0 = 32'd5;
    parameter [31:0] VECTOR_A_1 = 32'd2;
    parameter [31:0] VECTOR_A_2 = 32'd34;
    parameter [31:0] VECTOR_A_3 = 32'd4;
    parameter [31:0] VECTOR_B_0 = 32'd567;
    parameter [31:0] VECTOR_B_1 = 32'd6;
    parameter [31:0] VECTOR_B_2 = 32'd1000;
    parameter [31:0] VECTOR_B_3 = 32'd0;
    parameter [31:0] EXPECTED_RESULT = 32'd70; // 1*5 + 2*6 + 3*7 + 4*8
    
    // Instantiate the MIPS CPU
    MIPS_CPU dut (
        .clk(clk),
        .reset(reset),
        .pc_debug(debug_pc),
        .instruction_debug(debug_instruction),
        .alu_result_debug(debug_alu_result),
        .mem_data_debug(debug_mem_data)
    );
    
    // Clock generation
    always #(CLOCK_PERIOD/2) clk = ~clk;
    
    // Initialize data memory with test vectors
    initial begin
        // Wait for a few cycles after initialization
        #1;
        
        // Assembly code now uses byte addressing: 0, 4, 8, 12 for Vector A and 16, 20, 24, 28 for Vector B
        // These map to DRAM memory indices after address translation:
        // Byte addr 0 → mem[0], Byte addr 4 → mem[1], Byte addr 8 → mem[2], etc.
        
        // Initialize Vector A at byte addresses 0, 4, 8, 12 → memory indices 0, 1, 2, 3
        dut.dmem_inst.dram_inst.mem[0] = VECTOR_A_0;  // Byte address 0 → A[0] = 1
        dut.dmem_inst.dram_inst.mem[1] = VECTOR_A_1;  // Byte address 4 → A[1] = 2
        dut.dmem_inst.dram_inst.mem[2] = VECTOR_A_2;  // Byte address 8 → A[2] = 3
        dut.dmem_inst.dram_inst.mem[3] = VECTOR_A_3;  // Byte address 12 → A[3] = 4
        
        // Initialize Vector B at byte addresses 16, 20, 24, 28 → memory indices 4, 5, 6, 7
        dut.dmem_inst.dram_inst.mem[4] = VECTOR_B_0;  // Byte address 16 → B[0] = 5
        dut.dmem_inst.dram_inst.mem[5] = VECTOR_B_1;  // Byte address 20 → B[1] = 6
        dut.dmem_inst.dram_inst.mem[6] = VECTOR_B_2;  // Byte address 24 → B[2] = 7
        dut.dmem_inst.dram_inst.mem[7] = VECTOR_B_3;  // Byte address 28 → B[3] = 8
        
        $display("Data memory initialized with test vectors:");
        $display("Vector A: [%0d, %0d, %0d, %0d] at byte addresses 0, 4, 8, 12", 
                 VECTOR_A_0, VECTOR_A_1, VECTOR_A_2, VECTOR_A_3);
        $display("Vector B: [%0d, %0d, %0d, %0d] at byte addresses 16, 20, 24, 28", 
                 VECTOR_B_0, VECTOR_B_1, VECTOR_B_2, VECTOR_B_3);
        $display("Expected dot product: %0d", EXPECTED_RESULT);
        $display("");
    end
    
    // VCD file generation for waveform viewing
    initial begin
        $dumpfile("build/tb_InnerProduct.vcd");
        $dumpvars(0, tb_InnerProduct);
    end
    
    // Main test sequence
    integer cycle_count = 0;
    reg test_complete = 0;
    reg [31:0] final_result;
    
    initial begin
        $display("Starting dot product test...");
        $display("Time\t\tPC\t\tInstruction\tALU Result\tMem Data");
        $display("--------------------------------------------------------------------");
        
        // Hold reset for a few cycles
        repeat (3) @(posedge clk);
        reset = 0;
        
        // Monitor execution
        while (cycle_count < MAX_CYCLES && !test_complete) begin
            @(posedge clk);
            cycle_count = cycle_count + 1;
            
            // Display execution trace
            $display("%0t\t\t%08x\t%08x\t%08x\t%08x", 
                     $time, debug_pc, debug_instruction, debug_alu_result, debug_mem_data);
            
            // Check if we've reached the exit label (PC stops incrementing)
            if (cycle_count > 10 && debug_pc == 32'h38) begin // exit instruction address (0x38)
                test_complete = 1;
                // Read the final result from register $s6 (register 22)
                final_result = dut.rf_inst.gpregs[22]; // $s6 is register 22
                
                $display("");
                $display("=== TEST COMPLETED ===");
                $display("Execution stopped at PC = 0x%08x", debug_pc);
                $display("Total cycles executed: %0d", cycle_count);
                $display("Final dot product result: %0d", final_result);
                $display("Expected result: %0d", EXPECTED_RESULT);
                
                if (final_result == EXPECTED_RESULT) begin
                    $display("✓ TEST PASSED: Dot product calculated correctly!");
                end else begin
                    $display("✗ TEST FAILED: Expected %0d, got %0d", EXPECTED_RESULT, final_result);
                end
            end
        end
        
        if (!test_complete) begin
            $display("TEST TIMEOUT: Maximum cycles (%0d) reached", MAX_CYCLES);
            final_result = dut.rf_inst.gpregs[22];
            $display("Final result at timeout: %0d", final_result);
        end
        
        $display("");
        $display("=== REGISTER FILE STATE ===");
        $display("$s0 (r16): %08x", dut.rf_inst.gpregs[16]);
        $display("$s1 (r17): %08x", dut.rf_inst.gpregs[17]);
        $display("$s2 (r18): %08x", dut.rf_inst.gpregs[18]);
        $display("$s3 (r19): %08x", dut.rf_inst.gpregs[19]);
        $display("$s4 (r20): %08x", dut.rf_inst.gpregs[20]);
        $display("$s5 (r21): %08x", dut.rf_inst.gpregs[21]);
        $display("$s6 (r22): %08x (RESULT)", dut.rf_inst.gpregs[22]);
        $display("$t0 (r8):  %08x", dut.rf_inst.gpregs[8]);
        
        $finish;
    end
    
    // Timeout watchdog
    initial begin
        #(CLOCK_PERIOD * MAX_CYCLES * 2);
        $display("SIMULATION TIMEOUT");
        $finish;
    end

endmodule