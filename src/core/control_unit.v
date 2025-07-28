/**
 * @file src/core/control_unit.v
 * @brief Control Unit module for MIPS processor.
 * @author Artin Zarei | Mohsen Mirzaei
 */

module ControlUnit (
    input wire [5:0] opcode,
    input wire [5:0] funct,

    output wire Branch,  // high if branch instruction
    output wire Jump,    // high if jump instruction

    output wire MemRead,  // high if memory read
    output wire MemWrite,  // high if memory write
    output wire [1:0] RegWriteSrc, // Replaces MemtoReg. 00 for ALU result, 01 for memory read, 10 for PC+4, 11 for Crypt output.

    output wire RegWrite,  // high if register write is enabled
    output wire RegDst,    // high if destination register is rd (R-type) instead of rt (I-type)

    output wire [3:0] ALUOp,  // ALU operation code
    output wire ALUSrc,  // high if ALU source is immediate value instead of register

    output wire SignExtend  // high if sign extension is needed for immediate values
);

endmodule
