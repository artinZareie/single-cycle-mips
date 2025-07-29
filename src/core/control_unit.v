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

    // Jump things.
    assign Branch = opcode == 6'h04 || opcode == 6'h05 || opcode == 6'h01; // beq, bne, bltz, bgez
    assign Jump = (opcode == 6'h00 && (funct == 6'h08 || funct == 6'h09)) || opcode == 6'h02 || opcode == 6'h03; // jal, jr, j, jalr

    // Memory things.
    assign MemRead = opcode == 6'h23; // lw
    assign MemWrite = opcode == 6'h2B; // sw

    // GPRF things.
    assign RegWrite = ~(
        (opcode == 6'h00 && funct == 6'h08) || // jr
        opcode == 6'h02 || // j
        opcode == 6'h04 || // beq
        opcode == 6'h05 || // bne
        opcode == 6'h01 || // bltz, bgez
    );
    assign 

endmodule
