/*
 * @file src/core/alu.v
 * @brief ALU (Arithmetic Logic Unit) module for MIPS processor.
 * @author Artin Zarei | Mohsen Mirzaei
* @details Supports: add, sub, mul, and, xor, or, nor, neg, logical shift,
 * arithmetic shift, logical rotate.
 * ALU Control Signal Mapping:
 * 4'b0000 - ADD  (A + B)
 * 4'b0001 - SUB  (A - B)
 * 4'b0010 - MUL  (A * B)
 * 4'b0011 - AND  (A & B)
 * 4'b0100 - XOR  (A ^ B)
 * 4'b0101 - OR   (A | B)
* 4'b0110 - NOR  (~(A | B))
 * 4'b0111 - NEG  (-A)
 * 4'b1000 - SLL  (A << B[4:0]) - Logical shift left
 * 4'b1001 - SRL  (A >> B[4:0]) - Logical shift right
 * 4'b1010 - SLA  (A <<< B[4:0]) - Arithmetic shift left
 * 4'b1011 - SRA  (A >>> B[4:0]) - Arithmetic shift right
 * 4'b1100 - ROL  (A rotated left by B[4:0]) - Rotate left
 * 4'b1101 - ROR  (A rotated right by B[4:0]) - Rotate right
 * 4'b1110 - SLT  (Set Less Than) - Outputs 1 if A < B (signed), else 0
 * 4'b1111 - SLTU (Set Less Than Unsigned) - Outputs 1 if A < B (unsigned), else 0
 */

module ALU (
    input      [31:0] A,           // First operand
    input      [31:0] B,           // Second operand
    input      [ 3:0] ALUControl,  // Control signal to determine operation
    output reg [31:0] ALUResult,   // Result of the ALU operation
    output reg        Zero         // Zero flag
);

    always @(*) begin
        case (ALUControl)
            4'b0000: ALUResult = A + B;  // ADD
            4'b0001: ALUResult = A - B;  // SUB
            4'b0010: ALUResult = A * B;  // MUL
            4'b0011: ALUResult = A & B;  // AND
            4'b0100: ALUResult = A ^ B;  // XOR
            4'b0101: ALUResult = A | B;  // OR
            4'b0110: ALUResult = ~(A | B);  // NOR
            4'b0111: ALUResult = -A;  // NEG (2's Complement negation)
            4'b1000: ALUResult = A << B[4:0];  // SLL (Logical shift left)
            4'b1001: ALUResult = A >> B[4:0];  // SRL (Logical shift right)
            4'b1010: ALUResult = A <<< B[4:0];  // SLA (Arithmetic shift left)
            4'b1011: ALUResult = A >>> B[4:0];  // SRA (Arithmetic shift right)
            4'b1100: ALUResult = (A << B[4:0]) | (A >> (32 - B[4:0]));  // ROL (Rotate left)
            4'b1101: ALUResult = (A >> B[4:0]) | (A << (32 - B[4:0]));  // ROR (Rotate right)
            4'b1110: ALUResult = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;  // SLT (Set Less Than)
            4'b1111: ALUResult = (A < B) ? 32'd1 : 32'd0;  // SLTU (Set Less Than Unsigned)
            default: ALUResult = 32'h00000000;  // Zero by default
        endcase

        // Set Zero flag
        Zero = (ALUResult == 32'h00000000);
    end

endmodule
