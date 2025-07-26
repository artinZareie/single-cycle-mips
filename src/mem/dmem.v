/**
 * @file src/mem/dmem.v
 * @brief Data Memory module for MIPS processor.
 * @author Artin Zarei | Mohsen Mirzaei
 * @details Internally, uses DRAM.
 */

module DataMem (
    input  wire [31:0] addr,   // 32-bit address input
    input  wire        clk,    // Clock signal
    input  wire        we,     // Write enable
    input  wire [31:0] wdata,  // 32-bit write data input
    output wire [31:0] rdata   // 32-bit read data output
);

    DRAM dram_inst (
        .clk         (clk),
        .rst         (1'b0),   // Seems like I shouldn't have implemented reset.
        .addr        (addr),
        .wdata       (wdata),
        .write_enable(we),
        .rdata       (rdata)
    );

endmodule
