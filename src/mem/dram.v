/*
 * @file dram.v
 * @brief DRAM component module (connected to motherboard)
 * @author Artin Zarei | Mohsen Mirzaei
 * @details 4GiB, byte-addressable, little-endian, square 2D array (65536x65536),
 *          combinational read, write on negative clock edge. For simulation only.
 *          Intended for connection to motherboard bus.
 */

module DRAM #(
    parameter ADDR_WIDTH = 32,     // Address width (bits), 32 for 4GiB
    parameter DATA_WIDTH = 8,      // Data width (bits), 8 for byte-addressable
    parameter ROWS       = 65536,  // Number of rows (2^16 for square 4GiB)
    parameter COLS       = 65536   // Number of columns (2^16 for square 4GiB)
) (
    input  wire                  clk,           // Clock signal
    input  wire                  rst,           // Reset (zeroes all memory)
    input  wire [ADDR_WIDTH-1:0] addr,          // 32-bit byte address
    input  wire [DATA_WIDTH-1:0] wdata,         // Data to write (byte)
    input  wire                  write_enable,  // Write enable
    output reg  [DATA_WIDTH-1:0] rdata          // Data read (byte)
);
  // 2D array: ROWS x COLS, each cell is 8 bits (1 byte)
  reg [DATA_WIDTH-1:0] mem[0:ROWS-1][0:COLS-1];
  integer i, j;

  // Address decode: for small ADDR_WIDTH, use all bits for col, row=0
  wire [15:0] row = (ADDR_WIDTH > 16) ? addr[31:16] : 16'd0;
  wire [15:0] col = (ADDR_WIDTH > 16) ? addr[15:0] : addr[ADDR_WIDTH-1:0];

  initial begin
    // Initialize memory to zero
    for (i = 0; i < ROWS; i = i + 1) begin
      for (j = 0; j < COLS; j = j + 1) begin
        mem[i][j] = {DATA_WIDTH{1'b0}};
      end
    end
  end

  // Reset logic (zero entire memory)
  always @(posedge rst) begin
    for (i = 0; i < ROWS; i = i + 1) begin
      for (j = 0; j < COLS; j = j + 1) begin
        mem[i][j] = {DATA_WIDTH{1'b0}};
      end
    end
  end

  // Combinational read
  always @(*) begin
    if (rst) begin
      rdata = {DATA_WIDTH{1'b0}};
    end else begin
      rdata = mem[row][col];
    end
  end

  // Write on negative clock edge
  always @(negedge clk) begin
    if (write_enable) begin
      mem[row][col] <= wdata;
    end
  end

endmodule
