/*
 * @file sim/tb/immext_tb.v
 * @brief Testbench for the ImmExt module.
 */

`timescale 1ns / 1ps
module immext_tb;

  parameter CLK_PERIOD = 10;
  parameter MAX_TESTS = 100;

  reg clk;
  reg [15:0] immediate_tb;
  reg is_signed_tb;
  wire [31:0] imm_ext_tb;

  integer file_handle;
  integer scan_result;
  integer test_count;
  integer error_count;
  reg [31:0] expected_imm_ext;
  reg [200*8-1:0] line_buffer;

  ImmExt uut (
      .immediate(immediate_tb),
      .is_signed(is_signed_tb),
      .imm_ext  (imm_ext_tb)
  );

  initial begin
    clk = 0;
    repeat (MAX_TESTS * 2 + 20) @(posedge clk);
  end
  always #(CLK_PERIOD / 2) clk = ~clk;

  initial begin
    $dumpfile("build/immext_tb.vcd");
    $dumpvars(0, immext_tb);

    test_count   = 0;
    error_count  = 0;
    immediate_tb = 0;
    is_signed_tb = 0;

    #(CLK_PERIOD * 2);

    file_handle = $fopen("sim/stimuli/immext_ports.csv", "r");
    if (file_handle == 0) begin
      $display("ERROR: Could not open immext_ports.csv file");
      $finish;
    end

    $display("Starting ImmExt testbench with CSV stimuli...");
    $display("Format: [Test#] Type | Immediate | IsSigned | Result | Expected | Status");
    $display("----------------------------------------------------------------------");

    while (!$feof(
        file_handle
    ) && test_count < MAX_TESTS) begin
      scan_result = $fgets(line_buffer, file_handle);

      // Skip comments and empty lines
      if (scan_result && line_buffer[0] != "#" && line_buffer[0] != "\n" && line_buffer[0] != "\r") begin
        scan_result =
            $sscanf(line_buffer, "%h,%d,%h", immediate_tb, is_signed_tb, expected_imm_ext);

        if (scan_result == 3) begin
          // Wait for propagation delay
          #(CLK_PERIOD / 4);
          #1;

          // Check result
          if (imm_ext_tb !== expected_imm_ext) begin
            $display("FAIL [%0d] %s | 0x%04h | %b | 0x%08h | 0x%08h | MISMATCH", test_count,
                     is_signed_tb ? "SIGNED  " : "UNSIGNED", immediate_tb, is_signed_tb,
                     imm_ext_tb, expected_imm_ext);
            error_count = error_count + 1;
          end else begin
            $display("PASS [%0d] %s | 0x%04h | %b | 0x%08h | 0x%08h | OK", test_count,
                     is_signed_tb ? "SIGNED  " : "UNSIGNED", immediate_tb, is_signed_tb,
                     imm_ext_tb, expected_imm_ext);
          end

          test_count = test_count + 1;
        end
      end
    end

    // Close file and display summary
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
