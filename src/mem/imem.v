/**
 * @file src/mem/imem.v
 * @brief Instruction Memory module for MIPS processor.
 * @author Artin Zarei | Mohsen Mirzaei
 * @details Internally, uses DRAM. Handles 32-bit (word) accesses only.
 *          Takes byte addresses but performs word-aligned accesses.
 */

module InstMem (
    input  wire [31:0] addr,  // 32-bit byte address input (bottom 2 bits ignored for word alignment)
    input  wire        clk,   // Clock signal
    output wire [31:0] rdata  // 32-bit instruction output (full word)
);

    initial begin
        //TODO: Load the instruction memory with a program.
    end

    // 32-bit wide DRAM, word-aligned accesses
    DRAM #(
        .DATA_WIDTH(32),
        .ADDR_WIDTH(32)
    ) dram_inst (
        .clk         (clk),
        .rst         (1'b0),
        .addr        ({addr[31:2], 2'b00}),  // Word-aligned address
        .wdata       (32'b0), // No write in instruction memory
        .write_enable(1'b0),
        .rdata       (rdata)
    );

endmodule
