# Single-Cycle MIPS' ISA

This customized version of MIPS' ISA 16 instructions, including R-type, I-type and J-type instructions.

## R-type Instructions

Follows the standard regsiter-type MIPS conventions. The instructions are in this format:

| opcode (6 bits) = 0x0 | rs (5 bits) | rt (5 bits) | rd (5 bits) | shamt (5 bits) | funct (6 bits) |