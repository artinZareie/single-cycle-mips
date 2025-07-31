# Control Unit

The Control Unit is responsible for generating control signals.

## Control Signals

### Input Signals
- `opcode[5:0]`: 6-bit operation code from instruction[31:26]
- `funct[5:0]`: 6-bit function code from instruction[5:0] (used for R-type instructions)

### Output Signals
- `Branch`: High for branch instructions (beq, bne, bltz, bgez)
- `Jump`: High for jump instructions (j, jal, jr, jalr)
- `MemRead`: High for memory read operations (lw)
- `MemWrite`: High for memory write operations (sw)
- `RegWriteSrc[1:0]`: Selects source for register write data
  - 00: ALU result
  - 01: Memory read data
  - 10: PC+4 (for jal, jalr)
  - 11: Crypt output (for enc, dec)
- `RegWrite`: High when register write is enabled
- `RegDst[1:0]`: Selects destination register address
  - 00: rt field (I-type instructions)
  - 01: rd field (R-type instructions)
  - 10: Register 31 ($ra) for jal/jalr
  - 11: Reserved/unused
- `ALUOp[3:0]`: 4-bit ALU operation code
- `ALUSrc`: High when ALU second operand is immediate value, low when register
- `SignExtend`: High when immediate value needs sign extension

## Control Signal Table

| Instruction | Opcode | Funct | Branch | Jump | MemRead | MemWrite | RegWriteSrc | RegWrite | RegDst | ALUOp | ALUSrc | SignExtend |
|-------------|--------|-------|--------|------|---------|----------|-------------|----------|--------|-------|--------|------------|
| **R-type Instructions** |||||||||||||
| add | 0x00 | 0x20 | 0 | 0 | 0 | 0 | 00 | 1 | 01 | 0000 | 0 | X |
| sub | 0x00 | 0x22 | 0 | 0 | 0 | 0 | 00 | 1 | 01 | 0001 | 0 | X |
| mul | 0x00 | 0x18 | 0 | 0 | 0 | 0 | 00 | 1 | 01 | 0010 | 0 | X |
| and | 0x00 | 0x24 | 0 | 0 | 0 | 0 | 00 | 1 | 01 | 0011 | 0 | X |
| or | 0x00 | 0x25 | 0 | 0 | 0 | 0 | 00 | 1 | 01 | 0101 | 0 | X |
| xor | 0x00 | 0x26 | 0 | 0 | 0 | 0 | 00 | 1 | 01 | 0100 | 0 | X |
| nor | 0x00 | 0x27 | 0 | 0 | 0 | 0 | 00 | 1 | 01 | 0110 | 0 | X |
| sll | 0x00 | 0x00 | 0 | 0 | 0 | 0 | 00 | 1 | 01 | 1000 | 0 | X |
| srl | 0x00 | 0x02 | 0 | 0 | 0 | 0 | 00 | 1 | 01 | 1001 | 0 | X |
| sra | 0x00 | 0x03 | 0 | 0 | 0 | 0 | 00 | 1 | 01 | 1011 | 0 | X |
| sllv | 0x00 | 0x04 | 0 | 0 | 0 | 0 | 00 | 1 | 01 | 1000 | 0 | X |
| srlv | 0x00 | 0x06 | 0 | 0 | 0 | 0 | 00 | 1 | 01 | 1001 | 0 | X |
| srav | 0x00 | 0x07 | 0 | 0 | 0 | 0 | 00 | 1 | 01 | 1011 | 0 | X |
| rol | 0x00 | 0x1C | 0 | 0 | 0 | 0 | 00 | 1 | 01 | 1100 | 0 | X |
| ror | 0x00 | 0x1D | 0 | 0 | 0 | 0 | 00 | 1 | 01 | 1101 | 0 | X |
| rolv | 0x00 | 0x1E | 0 | 0 | 0 | 0 | 00 | 1 | 01 | 1100 | 0 | X |
| rorv | 0x00 | 0x1F | 0 | 0 | 0 | 0 | 00 | 1 | 01 | 1101 | 0 | X |
| slt | 0x00 | 0x2A | 0 | 0 | 0 | 0 | 00 | 1 | 01 | 1110 | 0 | X |
| sltu | 0x00 | 0x2B | 0 | 0 | 0 | 0 | 00 | 1 | 01 | 1111 | 0 | X |
| enc | 0x00 | 0x30 | 0 | 0 | 0 | 0 | 11 | 1 | 01 | XXXX | 0 | X |
| dec | 0x00 | 0x31 | 0 | 0 | 0 | 0 | 11 | 1 | 01 | XXXX | 0 | X |
| jr | 0x00 | 0x08 | 0 | 1 | 0 | 0 | XX | 0 | XX | XXXX | X | X |
| jalr | 0x00 | 0x09 | 0 | 1 | 0 | 0 | 10 | 1 | 10 | XXXX | X | X |
| **I-type Instructions** |||||||||||||
| addi | 0x08 | XX | 0 | 0 | 0 | 0 | 00 | 1 | 00 | 0000 | 1 | 1 |
| andi | 0x0C | XX | 0 | 0 | 0 | 0 | 00 | 1 | 00 | 0011 | 1 | 0 |
| ori | 0x0D | XX | 0 | 0 | 0 | 0 | 00 | 1 | 00 | 0101 | 1 | 0 |
| xori | 0x0E | XX | 0 | 0 | 0 | 0 | 00 | 1 | 00 | 0100 | 1 | 0 |
| slti | 0x0A | XX | 0 | 0 | 0 | 0 | 00 | 1 | 00 | 1110 | 1 | 1 |
| sltiu | 0x0B | XX | 0 | 0 | 0 | 0 | 00 | 1 | 00 | 1111 | 1 | 0 |
| lui | 0x0F | XX | 0 | 0 | 0 | 0 | 00 | 1 | 00 | XXXX | 1 | 0 |
| lw | 0x23 | XX | 0 | 0 | 1 | 0 | 01 | 1 | 00 | 0000 | 1 | 1 |
| sw | 0x2B | XX | 0 | 0 | 0 | 1 | XX | 0 | XX | 0000 | 1 | 1 |
| beq | 0x04 | XX | 1 | 0 | 0 | 0 | XX | 0 | XX | 0001 | 0 | 1 |
| bne | 0x05 | XX | 1 | 0 | 0 | 0 | XX | 0 | XX | 0001 | 0 | 1 |
| bltz | 0x01 | XX | 1 | 0 | 0 | 0 | XX | 0 | XX | XXXX | 0 | 1 |
| bgez | 0x01 | XX | 1 | 0 | 0 | 0 | XX | 0 | XX | XXXX | 0 | 1 |
| **J-type Instructions** |||||||||||||
| j | 0x02 | XX | 0 | 1 | 0 | 0 | XX | 0 | XX | XXXX | X | X |
| jal | 0x03 | XX | 0 | 1 | 0 | 0 | 10 | 1 | 10 | XXXX | X | X |

## Notes

- **X**: Don't care value (can be 0 or 1)
- **XX**: Don't care 2-bit value
- **XXXX**: Don't care 4-bit value
- For `bltz` and `bgez`, the `rt` field in the instruction distinguishes between them (0x00 for bltz, 0x01 for bgez)