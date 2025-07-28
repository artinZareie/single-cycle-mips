/*
 * @file crypt_tb.v
 * @brief Testbench for the Crypt module.
 * @details Tests the XOR-based symmetric encryption/decryption functionality
 *          using CSV test vectors. Validates that the module correctly performs
 *          XOR operations between data_in and key to produce data_out.
 */

`timescale 1ns / 1ps
module crypt_tb;

    parameter CLK_PERIOD = 10;
    parameter MAX_TESTS = 200;

    reg clk;
    reg [31:0] data_in_tb;
    reg [31:0] key_tb;
    wire [31:0] data_out_tb;

    integer file_handle;
    integer scan_result;
    integer test_count;
    integer error_count;
    reg [31:0] expected_data_out;
    reg [200*8-1:0] line_buffer;

    Crypt uut (
        .data_in(data_in_tb),
        .key(key_tb),
        .data_out(data_out_tb)
    );

    initial begin
        clk = 0;
        repeat (MAX_TESTS * 2 + 20) @(posedge clk);
    end
    always #(CLK_PERIOD / 2) clk = ~clk;

    initial begin
        $dumpfile("build/crypt_tb.vcd");
        $dumpvars(0, crypt_tb);

        test_count = 0;
        error_count = 0;
        data_in_tb = 0;
        key_tb = 0;

        #(CLK_PERIOD * 2);

        file_handle = $fopen("sim/stimuli/crypt_ports.csv", "r");
        if (file_handle == 0) begin
            $display("ERROR: Could not open crypt_ports.csv file");
            $finish;
        end

        $display("Starting Crypt testbench with CSV stimuli...");

        while (!$feof(
            file_handle
        ) && test_count < MAX_TESTS) begin
            scan_result = $fgets(line_buffer, file_handle);

            if (scan_result && line_buffer[0] != "#" && line_buffer[0] != "\n" && line_buffer[0] != "\r") begin
                scan_result =
                    $sscanf(line_buffer, "%d,%d,%d", data_in_tb, key_tb, expected_data_out);

                if (scan_result == 3) begin
                    #(CLK_PERIOD / 4);
                    #1;

                    if (data_out_tb !== expected_data_out) begin
                        $display(
                            "FAIL [%0d] XOR (Data^Key)\n  Data=0x%08h  Key=0x%08h\n  Result:   0x%08h\n  Expected: 0x%08h",
                            test_count, data_in_tb, key_tb, data_out_tb, expected_data_out);
                        error_count = error_count + 1;
                    end else begin
                        $display(
                            "PASS [%0d] XOR (Data^Key)  Data=0x%08h  Key=0x%08h  Result=0x%08h",
                            test_count, data_in_tb, key_tb, data_out_tb);
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

        // Additional validation: Test symmetric property
        $display("\n=== Symmetric Encryption Validation ===");
        test_symmetric_encryption();

        $finish;
    end


    task test_symmetric_encryption;
        reg [31:0] original_data;
        reg [31:0] encryption_key;
        reg [31:0] encrypted_data;
        reg [31:0] decrypted_data;
        integer sym_errors;
        integer i;

        begin
            sym_errors = 0;
            $display("Testing: encrypt(decrypt(data, key), key) = data");

            for (i = 0; i < 10; i = i + 1) begin
                case (i)
                    0: begin
                        original_data  = 32'h12345678;
                        encryption_key = 32'hABCDEF01;
                    end
                    1: begin
                        original_data  = 32'hDEADBEEF;
                        encryption_key = 32'h13579BDF;
                    end
                    2: begin
                        original_data  = 32'h00000000;
                        encryption_key = 32'hFFFFFFFF;
                    end
                    3: begin
                        original_data  = 32'hFFFFFFFF;
                        encryption_key = 32'h00000000;
                    end
                    4: begin
                        original_data  = 32'hAAAAAAAA;
                        encryption_key = 32'h55555555;
                    end
                    5: begin
                        original_data  = 32'h55555555;
                        encryption_key = 32'hAAAAAAAA;
                    end
                    6: begin
                        original_data  = 32'h12344321;
                        encryption_key = 32'h87654321;
                    end
                    7: begin
                        original_data  = 32'h11111111;
                        encryption_key = 32'h22222222;
                    end
                    8: begin
                        original_data  = 32'h80000000;
                        encryption_key = 32'h7FFFFFFF;
                    end
                    9: begin
                        original_data  = 32'h7FFFFFFF;
                        encryption_key = 32'h80000000;
                    end
                endcase

                data_in_tb = original_data;
                key_tb = encryption_key;
                #1;
                encrypted_data = data_out_tb;

                data_in_tb = encrypted_data;
                key_tb = encryption_key;
                #1;
                decrypted_data = data_out_tb;

                if (decrypted_data !== original_data) begin
                    $display(
                        "SYM_FAIL [%0d] Original=0x%08h Key=0x%08h Encrypted=0x%08h Decrypted=0x%08h",
                        i, original_data, encryption_key, encrypted_data, decrypted_data);
                    sym_errors = sym_errors + 1;
                end else begin
                    $display("SYM_PASS [%0d] Original=0x%08h Key=0x%08h", i, original_data,
                             encryption_key);
                end
            end

            if (sym_errors == 0) begin
                $display("Symmetric encryption property verified! ✓");
            end else begin
                $display("Symmetric encryption property FAILED! ✗");
            end
        end
    endtask

endmodule
