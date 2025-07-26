# Single-Cycle MIPS' ISA

This customized version of MIPS' ISA includes 16 instructions: R-type, I-type, and J-type.

## R-type Instruction Format

Computes an operation using two registers (or possibly one shift/rotate with one register), and saves
the result in a third (or second, in case of a shift/rotate) register.

| opcode (6 bits) | rs (5 bits) | rt (5 bits) | rd (5 bits) | shamt (5 bits) | funct (6 bits) |
|:--------------:|:-----------:|:-----------:|:-----------:|:--------------:|:--------------:|
|   Tied to 0x0  |             |             |             |                |                |

Overall convention (except for shifts/rotates):

```
rd = rs * rt
```

## I-type Instruction Format

Computes result of a 16-bits extended to 32-bits immediate with a register, and saves the result
into a register.

| opcode (6 bits) | rs (5 bits) | rt (5 bits) | immediate (16 bits) |
|:--------------:|:-----------:|:-----------:|:-------------------:|
|                |             |             |                     |

Overall Convention is:

```
rt = rs * imm
```

## J-type Instruction Format

Performs jump operations using a 26-bit address field. The target address is formed by combining
the upper 4 bits of the current PC with the 26-bit address field and 2 zero bits (for forced word alignment).

| opcode (6 bits) | address (26 bits) |
|:--------------:|:------------------:|
|                |                    |

