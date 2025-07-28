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


    // high for branch instructions
    assign Branch = (opcode == 6'h04) || (opcode == 6'h05) || (opcode == 6'h01) || (opcode == 6'h07);

    // high for jump instructions (j, jal, jr, jalr)
    assign Jump = (opcode == 6'h02) || (opcode == 6'h03) || 
                  (opcode == 6'h00 && (funct == 6'h08 || funct == 6'h09));

    // only for lw
    assign MemRead = (opcode == 6'h23);

    // only for sw
    assign MemWrite = (opcode == 6'h2B);

    assign RegWriteSrc = (opcode == 6'h23) ? 2'b01 :  // Memory data (lw)
        ((opcode == 6'h03) || (opcode == 6'h00 && funct == 6'h09)) ? 2'b10 :  // PC+4 (jal, jalr)
        (opcode == 6'h00 && (funct == 6'h30 || funct == 6'h31)) ? 2'b11 :      // Crypt output (enc, dec)
        2'b00;  // ALU result (default)

    // Register Write - high for most instructions except branches, jumps (except jal/jalr), and sw
    assign RegWrite = ~((opcode == 6'h04) || (opcode == 6'h05) || (opcode == 6'h01) || (opcode == 6'h07) ||  // branches
        (opcode == 6'h02) ||  // j
        (opcode == 6'h2B) ||  // sw
        (opcode == 6'h00 && funct == 6'h08));  // jr

    // Register Destination - high for R-type instructions (rd), low for I-type (rt)
    assign RegDst = (opcode == 6'h00);

    // ALU Source - high for immediate instructions
    assign ALUSrc = (opcode == 6'h08) || (opcode == 6'h0C) || (opcode == 6'h0D) || (opcode == 6'h0E) ||
                   (opcode == 6'h0A) || (opcode == 6'h0B) || (opcode == 6'h0F) ||
                   (opcode == 6'h23) || (opcode == 6'h2B);

    // high for arithmetic operations and memory operations
    assign SignExtend = (opcode == 6'h08) || (opcode == 6'h0A) || (opcode == 6'h0B) ||  // addi, slti, sltiu
        (opcode == 6'h23) || (opcode == 6'h2B) ||  // lw, sw
        (opcode == 6'h04) || (opcode == 6'h05) || (opcode == 6'h01) || (opcode == 6'h07);  // branches

    assign ALUOp = (opcode == 6'h00) ? ((funct == 6'h20) ? 4'b0000 :  // add
        (funct == 6'h22) ? 4'b0001 :  // sub
        (funct == 6'h18) ? 4'b0010 :  // mul
        (funct == 6'h24) ? 4'b0011 :  // and
        (funct == 6'h26) ? 4'b0100 :  // xor
        (funct == 6'h25) ? 4'b0101 :  // or
        (funct == 6'h27) ? 4'b0110 :  // nor
        (funct == 6'h00) ? 4'b1000 :  // sll
        (funct == 6'h02) ? 4'b1001 :  // srl
        (funct == 6'h03) ? 4'b1011 :  // sra
        (funct == 6'h04) ? 4'b1000 :  // sllv
        (funct == 6'h06) ? 4'b1001 :  // srlv
        (funct == 6'h07) ? 4'b1011 :  // srav
        (funct == 6'h1C) ? 4'b1100 :  // rol
        (funct == 6'h1D) ? 4'b1101 :  // ror
        (funct == 6'h1E) ? 4'b1100 :  // rolv
        (funct == 6'h1F) ? 4'b1101 :  // rorv
        (funct == 6'h2A) ? 4'b1110 :  // slt
        (funct == 6'h2B) ? 4'b1111 :  // sltu
        4'b0000) :  // default
        (opcode == 6'h08) ? 4'b0000 :  // addi
        (opcode == 6'h0C) ? 4'b0011 :  // andi
        (opcode == 6'h0D) ? 4'b0101 :  // ori
        (opcode == 6'h0E) ? 4'b0100 :  // xori
        (opcode == 6'h0A) ? 4'b1110 :  // slti
        (opcode == 6'h0B) ? 4'b1111 :  // sltiu
        (opcode == 6'h0F) ? 4'b1000 :  // lui (shift left)
        (opcode == 6'h23) ? 4'b0000 :  // lw (add for address)
        (opcode == 6'h2B) ? 4'b0000 :  // sw (add for address)
        (opcode == 6'h04) ? 4'b0001 :  // beq (subtract for comparison)
        (opcode == 6'h05) ? 4'b0001 :  // bne (subtract for comparison)
        (opcode == 6'h01) ? 4'b0000 :  // bltz
        (opcode == 6'h07) ? 4'b0000 :  // bgtz
        4'b0000;  // default

endmodule
