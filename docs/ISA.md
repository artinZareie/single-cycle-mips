# Single-Cycle MIPS' ISA

This customized version of MIPS' ISA includes 38 instructions: R-type, I-type, and J-type.

## R-type Instruction Format

Computes an operation using two registers (or possibly one shift/rotate with one register), and saves
the result in a third (or second, in case of a shift/rotate) register.

| opcode (6 bits) | rs (5 bits) | rt (5 bits) | rd (5 bits) | shamt (5 bits) | funct (6 bits) |
|:--------------:|:-----------:|:-----------:|:-----------:|:--------------:|:--------------:|
|   Tied to 0x0  |             |             |             |                |                |

Overall convention (except for shifts/rotates):

```
rd = rs op rt
```

But for Shift/Rotate with immediate, the convention is:

```
rd = rt shift/rotate shamt
```

For Variable Shift/Rotate (using register), the convention is:

```
rd = rt shift/rotate rs[4:0]
```

## I-type Instruction Format

Computes result of a 16-bits extended to 32-bits immediate with a register, and saves the result
into a register.

| opcode (6 bits) | rs (5 bits) | rt (5 bits) | immediate (16 bits) |
|:--------------:|:-----------:|:-----------:|:-------------------:|
|                |             |             |                     |

Overall Convention is:

```
rt = rs op imm
```

Note: For logical operations (andi, ori, xori), the 16-bit immediate is zero-extended to 32 bits.
For arithmetic operations (addi), the immediate is sign-extended to 32 bits.

But for branches, address mode is PC-relative. Displacement is calculated relative to PC + 4.

**Note:** Branch instructions `bltz` and `bgez` use opcode 0x01 with the `rt` field used to specify the branch condition type (0x00 for bltz, 0x01 for bgez).

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
| `mul` | R | `0x00` | `0x18` | `mul rd, rs, rt` | `rd = rs * rt`. |
| `and` | R | `0x00` | `0x24` | `and rd, rs, rt` | `rd = rs & rt`. |
| `or` | R | `0x00` | `0x25` | `or rd, rs, rt` | `rd = rs \| rt`. |
| `xor` | R | `0x00` | `0x26` | `xor rd, rs, rt` | `rd = rs ^ rt`. |
| `nor` | R | `0x00` | `0x27` | `nor rd, rs, rt` | `rd = ~(rs \| rt)`. |
| `sll` | R | `0x00` | `0x00` | `sll rd, rt, shamt` | `rd = rt << shamt`. |
| `srl` | R | `0x00` | `0x02` | `srl rd, rt, shamt` | `rd = rt >> shamt` (logical). |
| `sra` | R | `0x00` | `0x03` | `sra rd, rt, shamt` | `rd = rt >> shamt` (arithmetic, preserves sign). |
| `sllv` | R | `0x00` | `0x04` | `sllv rd, rt, rs` | `rd = rt << rs[4:0]` (variable shift left). |
| `srlv` | R | `0x00` | `0x06` | `srlv rd, rt, rs` | `rd = rt >> rs[4:0]` (variable shift right logical). |
| `srav` | R | `0x00` | `0x07` | `srav rd, rt, rs` | `rd = rt >> rs[4:0]` (variable shift right arithmetic). |
| `rol` | R | `0x00` | `0x1C` | `rol rd, rt, shamt` | `rd = rotate rt left by shamt`. |
| `ror` | R | `0x00` | `0x1D` | `ror rd, rt, shamt` | `rd = rotate rt right by shamt`. |
| `rolv` | R | `0x00` | `0x1E` | `rolv rd, rt, rs` | `rd = rotate rt left by rs[4:0]`. |
| `rorv` | R | `0x00` | `0x1F` | `rorv rd, rt, rs` | `rd = rotate rt right by rs[4:0]`. |
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
| `bltz` | I | `0x01` | | `bltz rs, label` | `if (rs < 0) branch` (rt field = 0x00). |
| `bgez` | I | `0x01` | | `bgez rs, label` | `if (rs >= 0) branch` (rt field = 0x01). |
| `j` | J | `0x02` | | `j label` | `PC = jump_target`. |
| `jal` | J | `0x03` | | `jal label` | `$ra = PC + 4; PC = jump_target`. |

## Opcode Summary

**R-type Instructions (opcode 0x00):**
- All R-type instructions use opcode 0x00.
- Function codes: 0x00 (sll), 0x02 (srl), 0x03 (sra), 0x04 (sllv), 0x06 (srlv), 0x07 (srav), 0x08 (jr), 0x09 (jalr), 0x18 (mul), 0x1C (rol), 0x1D (ror), 0x1E (rolv), 0x1F (rorv), 0x20 (add), 0x22 (sub), 0x24 (and), 0x25 (or), 0x26 (xor), 0x27 (nor), 0x2A (slt), 0x2B (sltu), 0x30 (enc), 0x31 (dec)

**I-type Instructions:**
- 0x01: bltz (rt=0x00), bgez (rt=0x01)
- 0x04: beq 
- 0x05: bne
- 0x08: addi
- 0x0A: slti
- 0x0B: sltiu
- 0x0C: andi
- 0x0D: ori
- 0x0E: xori
- 0x0F: lui
- 0x23: lw
- 0x2B: sw

**J-type Instructions:**
- 0x02: j
- 0x03: jal

## Key MIPS Compliance Notes

1. **Branch Instructions:** `bltz` and `bgez` both use opcode 0x01, with the `rt` field distinguishing between them (0x00 for bltz, 0x01 for bgez). This follows the standard MIPS encoding where these are variants of the same base instruction.

2. **R-type Instructions:** All R-type instructions use opcode 0x00 and are distinguished by their function codes as shown in the opcode summary.

3. **Address Calculation:** Jump target addresses are formed by concatenating PC[31:28] with the 26-bit address field shifted left by 2 bits.