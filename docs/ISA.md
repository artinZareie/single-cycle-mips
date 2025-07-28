# Single-Cycle MIPS' ISA

This customized version of MIPS' ISA includes 32 instructions: R-type, I-type, and J-type.

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

But for Shift/Rotate, the convention is:

```
rd = rs <<<>>> shamt
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

Note: For logical operations (andi, ori, xori), the 16-bit immediate is zero-extended to 32 bits.
For arithmetic operations (addi), the immediate is sign-extended to 32 bits.

But for branches, address mode is PC-relative. Dislocation is calculated relative to PC + 4.

## J-type Instruction Format

Performs jump operations using a 26-bit address field. The target address is formed by combining
the upper 4 bits of the current PC with the 26-bit address field and 2 zero bits (for forced word alignment).

| opcode (6 bits) | address (26 bits) |
|:--------------:|:------------------:|
|                |                    |

Address mode is absolute, not PC-relative.

## List of instructions

| Instruction | Type | Op (Hex) | Funct (Hex) | Mnemonic | Description |
|:---|:---:|:---:|:---:|:---|:---|
| `add` | R | `0x00` | `0x20` | `add rd, rs, rt` | `rd = rs + rt` (signed). |
| `sub` | R | `0x00` | `0x22` | `sub rd, rs, rt` | `rd = rs - rt` (signed). |
| `mul` | R | `0x00` | `0x1C` | `mul rd, rs, rt` | `rd = rs * rt`. |
| `and` | R | `0x00` | `0x24` | `and rd, rs, rt` | `rd = rs & rt`. |
| `or` | R | `0x00` | `0x25` | `or rd, rs, rt` | `rd = rs \| rt`. |
| `xor` | R | `0x00` | `0x26` | `xor rd, rs, rt` | `rd = rs ^ rt`. |
| `nor` | R | `0x00` | `0x27` | `nor rd, rs, rt` | `rd = ~(rs \| rt)`. |
| `sll` | R | `0x00` | `0x00` | `sll rd, rt, shamt` | `rd = rt << shamt`. |
| `srl` | R | `0x00` | `0x02` | `srl rd, rt, shamt` | `rd = rt >> shamt` (logical). |
| `sra` | R | `0x00` | `0x03` | `sra rd, rt, shamt` | `rd = rt >> shamt` (arithmetic, preserves sign). |
| `rol` | R | `0x00` | `0x19` | `rol rd, rt, shamt` | `rd = rotate rt left by shamt`. |
| `ror` | R | `0x00` | `0x1A` | `ror rd, rt, shamt` | `rd = rotate rt right by shamt`. |
| `slt` | R | `0x00` | `0x2A` | `slt rd, rs, rt` | `rd = (rs < rt)` (signed compare). |
| `sltu` | R | `0x00` | `0x2B` | `sltu rd, rs, rt` | `rd = (rs < rt)` (unsigned compare). |
| `enc` | R | `0x00` | `0x30` | `enc rd, rs, rt` | `rd = encrypt(rs, rt)`. |
| `dec` | R | `0x00` | `0x31` | `dec rd, rs, rt` | `rd = decrypt(rs, rt)`. |
| `jr` | R | `0x00` | `0x08` | `jr rs` | `PC = rs`. |
| `jalr` | R | `0x00` | `0x09` | `jalr rd, rs` | `rd = PC + 4; PC = rs`. |
| `addi` | I | `0x08` | | `addi rt, rs, imm` | `rt = rs + imm` (signed). |
| `andi` | I | `0x0C` | | `andi rt, rs, imm` | `rt = rs & imm` (zero-extended). |
| `ori` | I | `0x0D` | | `ori rt, rs, imm` | `rt = rs \| imm` (zero-extended). |
| `xori` | I | `0x0E` | | `xori rt, rs, imm` | `rt = rs ^ imm` (zero-extended). |
| `slti` | I | `0x0A` | | `slti rt, rs, imm` | `rt = (rs < imm)` (signed compare). |
| `sltiu` | I | `0x0B` | | `sltiu rt, rs, imm` | `rt = (rs < imm)` (unsigned compare). |
| `lui` | I | `0x0F` | | `lui rt, imm` | `rt = imm << 16` (load upper immediate). |
| `lw` | I | `0x23` | | `lw rt, imm(rs)` | `rt = MEM[rs + imm]` (32-bit load). |
| `sw` | I | `0x2B` | | `sw rt, imm(rs)` | `MEM[rs + imm] = rt` (32-bit store). |
| `beq` | I | `0x04` | | `beq rs, rt, label` | `if (rs == rt) branch`. |
| `bne` | I | `0x05` | | `bne rs, rt, label` | `if (rs != rt) branch`. |
| `bltz` | I | `0x01` | | `bltz rs, label` | `if (rs < 0) branch`. |
| `blez` | I | `0x06` | | `blez rs, label` | `if (rs <= 0) branch`. |
| `bgtz` | I | `0x07` | | `bgtz rs, label` | `if (rs > 0) branch`. |
| `bgez` | I | `0x07` | | `bgez rs, label` | `if (rs >= 0) branch`. |
| `j` | J | `0x02` | | `j label` | `PC = jump_target`. |
| `jal` | J | `0x03` | | `jal label` | `$ra = PC + 4; PC = jump_target`. |