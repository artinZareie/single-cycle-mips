/*
 * @file dram.v
 * @brief DRAM component module (connected to motherboard)
 * @author Artin Zarei | Mohsen Mirzaei
 * @details Sparse memory implementation for simulation efficiency.
 *          Uses associative array to only allocate memory for accessed locations.
 *          Combinational read, write on negative clock edge.
 */

module DRAM #(
    parameter ADDR_WIDTH = 32,     // Address width (bits)
    parameter DATA_WIDTH = 8,      // Data width (bits), 8 for byte-addressable, 32 for word-addressable
    parameter ROWS       = 65536,  // Kept for backward compatibility (unused)
    parameter COLS       = 65536   // Kept for backward compatibility (unused)
) (
    input  wire                  clk,           // Clock signal
    input  wire                  rst,           // Reset signal
    input  wire [ADDR_WIDTH-1:0] addr,          // Address for access
    input  wire [DATA_WIDTH-1:0] wdata,         // Data to write
    input  wire                  write_enable,  // Write enable
    output wire [DATA_WIDTH-1:0] rdata          // Data read
);
    
    // Sparse memory implementation using associative array
    // Only allocates memory for addresses that are actually written to
    reg [DATA_WIDTH-1:0] mem[integer];
    
    // Combinational read - returns 0 for unwritten locations, actual data for written ones
    assign rdata = rst ? {DATA_WIDTH{1'b0}} : 
                   mem.exists(addr) ? mem[addr] : {DATA_WIDTH{1'b0}};
    
    // Sequential write
    always @(negedge clk) begin
        if (write_enable && !rst) begin
            mem[addr] <= wdata;
        end
    end
    
    // Reset operation - clears all allocated memory
    always @(posedge rst) begin
        mem.delete();
    end

endmodule
