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
    output wire [1:0] RegDst,  // high if destination register is rd (R-type) instead of rt (I-type)

    output wire ALUSrc,  // high if ALU source is immediate value instead of register

    output wire SignExtend,  // high if sign extension is needed for immediate values

    // New control signals for shift/rotate operand selection
    output wire ShiftOp,      // high for shift/rotate instructions
    output wire VarShift      // high for variable shift/rotate (uses rs as shift amount)
);

    // Jump things.
    assign Branch = opcode == 6'h04 || opcode == 6'h05 || opcode == 6'h01;  // beq, bne, bltz, bgez
    assign Jump = (opcode == 6'h00 && (funct == 6'h08 || funct == 6'h09)) || opcode == 6'h02 || opcode == 6'h03; // jal, jr, j, jalr

    // Shift/rotate detection
    assign ShiftOp = (opcode == 6'h00) && (
        funct == 6'h00 || funct == 6'h02 || funct == 6'h03 || // sll, srl, sra
        funct == 6'h1C || funct == 6'h1D ||                   // rol, ror
        funct == 6'h04 || funct == 6'h06 || funct == 6'h07 || // sllv, srlv, srav
        funct == 6'h1E || funct == 6'h1F                      // rolv, rorv
    );
    assign VarShift = (opcode == 6'h00) && (
        funct == 6'h04 || funct == 6'h06 || funct == 6'h07 || // sllv, srlv, srav
        funct == 6'h1E || funct == 6'h1F                      // rolv, rorv
    );

    // Memory things.
    assign MemRead = opcode == 6'h23;  // lw
    assign MemWrite = opcode == 6'h2B;  // sw

    // GPRF things.
    assign RegWrite = ~((opcode == 6'h00 && funct == 6'h08) ||  // jr
        opcode == 6'h02 ||  // j
        opcode == 6'h04 ||  // beq
        opcode == 6'h05 ||  // bne
        opcode == 6'h01 ||  // bltz, bgez
        opcode == 6'h2B  // sw
        );

    assign RegDst = (opcode == 6'h00 && funct == 6'h09) || opcode == 6'h03 ? 2'b10 :  // jalr, jal
        (opcode == 6'h00) ? 2'b01 :  // R-type instructions use rd
        2'b00;

    assign RegWriteSrc = (opcode == 6'h00 && (funct == 6'h30 || funct == 6'h31)) ? 2'b11 : // Crypt instructions
        ((opcode == 6'h00 && funct == 6'h09) || opcode == 6'h03) ? 2'b10 :  // jalr, jal
        (opcode == 6'h23) ? 2'b01 :  // lw
        2'b00;  // ALU result

    // ALU things.
    assign ALUSrc = ~(opcode == 6'h00 ||  // R-type instructions
        opcode == 6'h01 ||  // bltz, bgez
        opcode == 6'h04 ||  // beq
        opcode == 6'h05  // bne
        );

    assign SignExtend = ~(opcode == 6'h0C ||  // andi
        opcode == 6'h0D ||  // ori
        opcode == 6'h0E ||  // xori
        opcode == 6'h0F ||  // lui
        opcode == 6'h0B  // sltiu
        );

endmodule
