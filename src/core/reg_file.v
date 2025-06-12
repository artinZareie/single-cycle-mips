/*
 * @file reg_file.v
 * @brief GPRegister File module for MIPS processor. Contains 32 general-purpose registers.
 * @author Artin Zarei | Mohsen Mirzaei
 * @details Supports 2 read ports and 1 write port. Read is combinational, 
 * write is synchronous on positive clock edge. Address $0 is hardwired to zero.
 * Requries 5-bit address.
 */

module RegisterFile (
    input wire clk,               // Clock signal
    input wire rst,               // Reset signal (zeroes all registers)
    input wire [4:0] address_A,   // Address of first register to read
    input wire [4:0] address_B,   // Address of second register to read
    input wire [4:0] address_W,   // Address of register to write
    input wire [31:0] write_data, // Data to write into the register
    input wire write_enable,      // Control signal for writing to the register
    output reg [31:0] reg_A,      // Data from first register
    output reg [31:0] reg_B       // Data from second register
);

    reg [31:0] gpregs [31:0];
    integer i;

    // Initialize all registers to zero at startup
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            gpregs[i] = 32'b0;
        end
    end

    // Read logic (combinational)
    always @(*) begin
        reg_A = (address_A == 5'b00000) ? 32'b0 : gpregs[address_A]; // Register $0 is hardwired to zero
        reg_B = (address_B == 5'b00000) ? 32'b0 : gpregs[address_B]; // Register $0 is hardwired to zero
    end

    // Write logic (synchronous) and reset
    always @(posedge clk) begin
        if (rst) begin
            // Initialize all registers to zero
            for (i = 0; i < 32; i = i + 1) begin
                gpregs[i] <= 32'b0;
            end
        end else if (write_enable && address_W != 5'b00000) begin
            // Write to register (excluding register 0)
            gpregs[address_W] <= write_data;
        end
    end
    
endmodule
