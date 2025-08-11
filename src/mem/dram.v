/*
 * @file dram.v
 * @brief DRAM component module (connected to motherboard)
 * @author Artin Zarei | Mohsen Mirzaei
 * @details Memory implementation for simulation.
 *          Uses a reasonable-sized array for simulation.
 *          Combinational read, write on negative clock edge.
 */

module DRAM #(
    parameter ADDR_WIDTH = 32,     // Address width (bits)
    parameter DATA_WIDTH = 8,      // Data width (bits), 8 for byte-addressable, 32 for word-addressable
    parameter MEM_SIZE   = 1024    // Memory size in words (4KB for a 32-bit memory)
) (
    input  wire                  clk,           // Clock signal
    input  wire                  rst,           // Reset signal
    input  wire [ADDR_WIDTH-1:0] addr,          // Address for access
    input  wire [DATA_WIDTH-1:0] wdata,         // Data to write
    input  wire                  write_enable,  // Write enable
    output reg  [DATA_WIDTH-1:0] rdata          // Data read
);
    
    // Memory implementation - sized appropriately for simulation
    reg [DATA_WIDTH-1:0] mem[0:MEM_SIZE-1];
    
    // Read logic - returns 0 for out-of-bounds addresses
    always @(*) begin
        if (rst || addr[ADDR_WIDTH-1:2] >= MEM_SIZE)
            rdata = {DATA_WIDTH{1'b0}};
        else
            rdata = mem[addr[ADDR_WIDTH-1:2]]; // Word-aligned addressing
    end
    
    // Write logic
    always @(posedge clk) begin
        if (write_enable && !rst && addr[ADDR_WIDTH-1:2] < MEM_SIZE) begin
            mem[addr[ADDR_WIDTH-1:2]] <= wdata;
        end
    end
    
    // Reset logic - we don't clear memory on reset to save simulation time
    // If you need explicit zeroing, uncomment this block
    /*
    integer i;
    always @(posedge rst) begin
        for (i = 0; i < MEM_SIZE; i = i + 1)
            mem[i] <= {DATA_WIDTH{1'b0}};
    end
    */

endmodule