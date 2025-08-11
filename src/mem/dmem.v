/**
 * @file src/mem/dmem.v
 * @brief Data Memory module for MIPS processor.
 * @author Artin Zarei | Mohsen Mirzaei
 * @details Internally, uses DRAM. Handles 32-bit (word) accesses only.
 *          Takes byte addresses but performs word-aligned accesses.
 */

module DataMem (
    input  wire [31:0] addr,   // 32-bit byte address input (bottom 2 bits ignored for word alignment)
    input  wire        clk,    // Clock signal
    input  wire        we,     // Write enable
    input  wire [31:0] wdata,  // 32-bit write data input (full word)
    output wire [31:0] rdata   // 32-bit read data output (full word)
);

    // Use a 32-bit wide DRAM and align to word boundaries (assume word-aligned accesses)
    DRAM #(
        .DATA_WIDTH(32),
        .ADDR_WIDTH(32)
    ) dram_inst (
        .clk         (clk),
        .rst         (1'b0),
        .addr        ({addr[31:2], 2'b00}),  // Word-aligned address
        .wdata       (wdata),
        .write_enable(we),
        .rdata       (rdata)
    );

endmodule
