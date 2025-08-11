# Single-Cycle MIPS ISA

This project implements the following instruction set. The CPU, Control Unit, and ALU handle the instructions listed below.

Instruction groups:
- R-type arithmetic/logical: add, sub, mul, and, or, xor, shifts, rotates
- I-type arithmetic/memory: addi, subi, lw, sw
- Control transfer: jmp, beq
- Custom crypto: enc, dec

## R-type Instruction Format

Computes an operation using two registers (or one register plus a shift amount), and writes the result to a destination register.

| opcode (6 bits) | rs (5 bits) | rt (5 bits) | rd (5 bits) | shamt (5 bits) | funct (6 bits) |
|:--------------:|:-----------:|:-----------:|:-----------:|:--------------:|:--------------:|
|   0x00         |             |             |             |                |                |

General convention (except shift/rotate immediates):

```
rd = rs op rt
```

Shift/Rotate with immediate:

```
rd = rt shift/rotate shamt
```

Variable Shift/Rotate (register-based amount):

```
rd = rt shift/rotate rs[4:0]
```

## I-type Instruction Format

Performs an operation using a 16-bit immediate (extended to 32 bits) and a register, writing the result to a register; or accesses memory with base+offset addressing.

| opcode (6 bits) | rs (5 bits) | rt (5 bits) | immediate (16 bits) |
|:--------------:|:-----------:|:-----------:|:-------------------:|
|                |             |             |                     |

Convention:

```
rt = rs op imm
```

Immediates for arithmetic (addi/subi, lw/sw offsets) are sign-extended to 32 bits.

## J-type Instruction Format

Performs an absolute jump using a 26-bit address field. The target is formed by combining PC[31:28], the 26-bit field, and two trailing zero bits (word aligned).

| opcode (6 bits) | address (26 bits) |
|:--------------:|:------------------:|
|                |                    |

## Instruction List

| Instruction | Type | Op (Hex) | Funct (Hex) | Mnemonic | Description |
|:---|:---:|:---:|:---:|:---|:---|
| `add` | R | `0x00` | `0x20` | `add rd, rs, rt` | `rd = rs + rt` (signed). |
| `sub` | R | `0x00` | `0x22` | `sub rd, rs, rt` | `rd = rs - rt` (signed). |
| `mul` | R | `0x00` | `0x18` | `mul rd, rs, rt` | `rd = rs * rt`. |
| `and` | R | `0x00` | `0x24` | `and rd, rs, rt` | `rd = rs & rt`. |
| `or`  | R | `0x00` | `0x25` | `or rd, rs, rt`  | `rd = rs \| rt`. |
| `xor` | R | `0x00` | `0x26` | `xor rd, rs, rt` | `rd = rs ^ rt`. |
| `sll` | R | `0x00` | `0x00` | `sll rd, rt, shamt` | `rd = rt << shamt`. |
| `srl` | R | `0x00` | `0x02` | `srl rd, rt, shamt` | `rd = rt >> shamt` (logical). |
| `sra` | R | `0x00` | `0x03` | `sra rd, rt, shamt` | `rd = rt >> shamt` (arithmetic). |
| `sllv`| R | `0x00` | `0x04` | `sllv rd, rt, rs`   | `rd = rt << rs[4:0]`. |
| `srlv`| R | `0x00` | `0x06` | `srlv rd, rt, rs`   | `rd = rt >> rs[4:0]` (logical). |
| `srav`| R | `0x00` | `0x07` | `srav rd, rt, rs`   | `rd = rt >> rs[4:0]` (arithmetic). |
| `rol` | R | `0x00` | `0x1C` | `rol rd, rt, shamt` | `rd = rotate-left(rt, shamt)`. |
| `ror` | R | `0x00` | `0x1D` | `ror rd, rt, shamt` | `rd = rotate-right(rt, shamt)`. |
| `rolv`| R | `0x00` | `0x1E` | `rolv rd, rt, rs`   | `rd = rotate-left(rt, rs[4:0])`. |
| `rorv`| R | `0x00` | `0x1F` | `rorv rd, rt, rs`   | `rd = rotate-right(rt, rs[4:0])`. |
| `enc` | R | `0x00` | `0x30` | `enc rd, rs, rt` | `rd = encrypt(rs, rt)` (custom). |
| `dec` | R | `0x00` | `0x31` | `dec rd, rs, rt` | `rd = decrypt(rs, rt)` (custom). |
| `addi`| I | `0x08` |        | `addi rt, rs, imm` | `rt = rs + imm` (signed imm). |
| `subi`| I | `0x08` |        | `subi rt, rs, imm` | Alias of `addi rt, rs, -imm`; assembler form for subtraction with immediate. |
| `lw`  | I | `0x23` |        | `lw rt, imm(rs)`   | `rt = MEM[rs + imm]` (32-bit load). |
| `sw`  | I | `0x2B` |        | `sw rt, imm(rs)`   | `MEM[rs + imm] = rt` (32-bit store). |
| `beq` | I | `0x04` |        | `beq rs, rt, label` | if `(rs == rt)` then `PC = PC + 4 + (imm << 2)`. |
| `jmp` | J | `0x02` |        | `jmp label`        | `PC = {PC[31:28], addr[25:0], 2'b00}` (absolute jump). |

## Opcode Summary

**R-type (opcode 0x00):** funct codes used: 0x00 (sll), 0x02 (srl), 0x03 (sra), 0x04 (sllv), 0x06 (srlv), 0x07 (srav), 0x18 (mul), 0x1C (rol), 0x1D (ror), 0x1E (rolv), 0x1F (rorv), 0x20 (add), 0x22 (sub), 0x24 (and), 0x25 (or), 0x26 (xor), 0x30 (enc), 0x31 (dec)

**I-type:** 0x04 (beq), 0x08 (addi / subi alias), 0x23 (lw), 0x2B (sw)

**J-type:** 0x02 (jmp)

## Notes

1. Immediates used by addi/subi and lw/sw offsets are sign-extended before use.
2. `subi` is treated as assembler syntax and maps to `addi` with a negated immediate; no separate opcode is required.
3. Branch targets (beq) are PC-relative and word-aligned: `PC_next = PC + 4 + (signext(imm) << 2)` when taken.
4. Jump targets (jmp) are absolute and word-aligned: `{PC[31:28], addr[25:0], 2'b00}`.