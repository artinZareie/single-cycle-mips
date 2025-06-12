/*
 * @file alu_tb.v
 * @brief Testbench for the ALU module.
 */

`timescale 1ns / 1ps
module alu_tb;

    parameter CLK_PERIOD = 10;
    parameter MAX_TESTS = 100;

    reg clk;
    reg [31:0] A_tb;
    reg [31:0] B_tb;
    reg [3:0] ALUControl_tb;
    wire [31:0] ALUResult_tb;
    wire Zero_tb;

    integer file_handle;
    integer scan_result;
    integer test_count;
    integer error_count;
    reg [31:0] expected_ALUResult;
    reg expected_Zero;
    reg [200*8-1:0] line_buffer;
    reg [32*8-1:0] op_name;

    // Simple operation name function (no $sformatf)
    function [32*8-1:0] get_op_name;
        input [3:0] alu_ctrl;
        begin
            case (alu_ctrl)
                4'b0000: get_op_name = "ADD (A+B)   ";
                4'b0001: get_op_name = "SUB (A-B)   ";
                4'b0010: get_op_name = "MUL (A*B)   ";
                4'b0011: get_op_name = "AND (A&B)   ";
                4'b0100: get_op_name = "XOR (A^B)   ";
                4'b0101: get_op_name = "OR  (A|B)   ";
                4'b0110: get_op_name = "NOT (~A)    ";
                4'b0111: get_op_name = "NEG (-A)    ";
                4'b1000: get_op_name = "SLL (A<<B)  ";
                4'b1001: get_op_name = "SRL (A>>B)  ";
                4'b1010: get_op_name = "SLA (A<<<B) ";
                4'b1011: get_op_name = "SRA (A>>>B) ";
                4'b1100: get_op_name = "ROL (A rol) ";
                4'b1101: get_op_name = "ROR (A ror) ";
                default: get_op_name = "UNKNOWN     ";
            endcase
        end
    endfunction

    ALU uut (
        .A(A_tb),
        .B(B_tb),
        .ALUControl(ALUControl_tb),
        .ALUResult(ALUResult_tb),
        .Zero(Zero_tb)
    );

    initial begin
        clk = 0;
        repeat (MAX_TESTS * 2 + 20) @(posedge clk);
    end
    always #(CLK_PERIOD / 2) clk = ~clk;

    initial begin
        $dumpfile("build/alu_tb.vcd");
        $dumpvars(0, alu_tb);
        test_count = 0;
        error_count = 0;
        A_tb = 0;
        B_tb = 0;
        ALUControl_tb = 0;
        # (CLK_PERIOD * 2);
        file_handle = $fopen("sim/stimuli/alu_ports.csv", "r");
        if (file_handle == 0) begin
            $display("ERROR: Could not open alu_ports.csv file");
            $finish;
        end
        $display("Starting ALU testbench with CSV stimuli...");
        while (!$feof(file_handle) && test_count < MAX_TESTS) begin
            scan_result = $fgets(line_buffer, file_handle);
            if (scan_result && line_buffer[0] != "#" && line_buffer[0] != "\n" && line_buffer[0] != "\r") begin
                scan_result = $sscanf(line_buffer, "%d,%d,%d,%d,%d",
                    A_tb, B_tb, ALUControl_tb, expected_ALUResult, expected_Zero);
                if (scan_result == 5) begin
                    #(CLK_PERIOD / 4);
                    #1;
                    op_name = get_op_name(ALUControl_tb);
                    if (ALUResult_tb !== expected_ALUResult) begin
                        $display("FAIL [%0d] %s\n  A=0x%08h  B=0x%08h  Ctrl=%2d\n  Result:   0x%08h\n  Expected: 0x%08h",
                            test_count, op_name, A_tb, B_tb, ALUControl_tb, ALUResult_tb, expected_ALUResult);
                        error_count = error_count + 1;
                    end
                    if (Zero_tb !== expected_Zero) begin
                        $display("FAIL [%0d] %s\n  A=0x%08h  B=0x%08h  Ctrl=%2d\n  Zero:     %b\n  Expected: %b (Result: 0x%08h)",
                            test_count, op_name, A_tb, B_tb, ALUControl_tb, Zero_tb, expected_Zero, ALUResult_tb);
                        error_count = error_count + 1;
                    end
                    if (ALUResult_tb === expected_ALUResult && Zero_tb === expected_Zero) begin
                        $display("PASS [%0d] %s  A=0x%08h  B=0x%08h  Ctrl=%2d  Result=0x%08h  Zero=%b",
                            test_count, op_name, A_tb, B_tb, ALUControl_tb, ALUResult_tb, Zero_tb);
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