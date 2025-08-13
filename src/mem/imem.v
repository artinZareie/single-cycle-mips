/**
 * @file src/mem/imem.v
 * @brief Instruction Memory module for MIPS processor.
 * @author Artin Zarei | Mohsen Mirzaei
 * @details Contains a ROM for instruction storage with $readmemh capability.
 *          Handles 32-bit (word) accesses only, word-aligned.
 */

module InstMem (
    input  wire [31:0] addr,  // 32-bit byte address input (bottom 2 bits ignored for word alignment)
    input  wire        clk,   // Clock signal
    output wire [31:0] rdata  // 32-bit instruction output (full word)
);

    // Simple ROM for instruction storage (1024 words = 4KB)
    localparam ROM_WORDS = 1024;
    reg [31:0] rom [0:ROM_WORDS-1];
    
    // Load program from hex file
    initial begin
        $readmemh("sim/stimuli/assembled.hex", rom);
    end
    
    // Word-aligned read from ROM
    wire [31:0] word_addr = addr[31:2]; // Convert byte address to word address
    assign rdata = (word_addr < ROM_WORDS) ? rom[word_addr] : 32'h00000000;

endmodule
