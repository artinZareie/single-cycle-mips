/**
 * @file src/mem/imem.v
 * @brief Instruction Memory module for MIPS processor.
 * @author Artin Zarei | Mohsen Mirzaei
 * @details Internally, uses DRAM.
 */

module InstMem (
    input  wire [31:0] addr,  // 32-bit address input.
    input  wire        clk,   // Clock signal.
    output wire [31:0] rdata  // 32-bit opcode output.
);

    initial begin
        //TODO: Load the instruction memory with a program.
    end

    DRAM dram_inst (
        .clk         (clk),
        .rst         (1'b0),  // Tie reset to 0. No reset should happen.
        .addr        (addr),
        .wdata       (8'b0),  // Write is not a thing in instruction memory.
        .write_enable(1'b0),  // As I said.
        .rdata       (rdata)
    );

endmodule
