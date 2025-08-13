# MIPS_CPU (Single-Cycle MIPS Processor)

The MIPS_CPU is the top-level module that implements a single-cycle MIPS processor. It integrates all components including the control unit, ALU, register file, memory subsystem, and supporting modules to execute MIPS instructions in a single clock cycle.

## Overview

This single-cycle implementation executes each instruction in exactly one clock cycle by having dedicated hardware for each stage of instruction execution. The processor supports:

- **R-type instructions**: Arithmetic, logical, shift, and rotate operations
- **I-type instructions**: Immediate arithmetic, memory operations (load/store), and conditional branches
- **J-type instructions**: Jump operations
- **Custom instructions**: Encryption/decryption operations

## Architecture

The processor follows the classic MIPS datapath with the following major components:

1. **Program Counter (PC)** - Tracks current instruction address
2. **Instruction Memory** - Stores program instructions
3. **Control Unit** - Generates control signals for all operations
4. **Register File** - 32 general-purpose registers
5. **ALU** - Performs arithmetic and logical operations
6. **Data Memory** - Stores program data
7. **Immediate Extension** - Sign/zero extends immediate values
8. **Crypto Unit** - Handles encryption/decryption operations

## Interface

```verilog
module MIPS_CPU(
    input wire clk,                    // System clock
    input wire reset,                  // Synchronous reset
    
    output wire [31:0] pc_debug,           // Current PC value (for debugging)
    output wire [31:0] instruction_debug,  // Current instruction (for debugging)
    output wire [31:0] alu_result_debug,   // ALU result (for debugging)
    output wire [31:0] mem_data_debug      // Memory read data (for debugging)
);
```

## Datapath Components

### Program Counter Management
- **PC+4 calculation**: Sequential instruction addressing
- **Branch address**: `PC + 4 + (sign_ext_imm << 2)`
- **Jump address**: `{PC[31:28], instruction[25:0], 2'b00}`
- **PC source selection**: 4:1 mux controlled by branch/jump logic

### Register Addressing Logic
The processor handles special register addressing for shift/rotate operations:
- **Normal operations**: `A = rs`, `B = rt`
- **Shift/rotate with immediate**: `A = rt`, `B = shamt`
- **Variable shift/rotate**: `A = rt`, `B = rs`

### ALU Input Selection
- **Input A**: Always from register file read port A
- **Input B**: Multiplexed between:
  - Register file read port B (R-type operations)
  - Sign/zero-extended immediate (I-type operations)
  - Shift amount immediate (`shamt` field, zero-extended)

### Write-Back Data Selection
The register file write data comes from a 4:1 multiplexer:
- **00**: ALU result (arithmetic/logical operations)
- **01**: Memory read data (load instructions)
- **10**: PC+4 (jump-and-link operations)
- **11**: Crypto unit output (encryption/decryption)

### Destination Register Selection
- **R-type**: `rd` field (instruction[15:11])
- **I-type**: `rt` field (instruction[20:16])
- **Jump-and-link**: Register 31 ($ra)

## Supported Instruction Set

### R-Type Instructions (opcode = 0x00)
| Instruction | Funct | Operation | Description |
|-------------|-------|-----------|-------------|
| `add` | 0x20 | `rd = rs + rt` | Addition |
| `sub` | 0x22 | `rd = rs - rt` | Subtraction |
| `mul` | 0x18 | `rd = rs * rt` | Multiplication |
| `and` | 0x24 | `rd = rs & rt` | Bitwise AND |
| `or` | 0x25 | `rd = rs \| rt` | Bitwise OR |
| `xor` | 0x26 | `rd = rs ^ rt` | Bitwise XOR |
| `nor` | 0x27 | `rd = ~(rs \| rt)` | Bitwise NOR |
| `sll` | 0x00 | `rd = rt << shamt` | Logical shift left |
| `srl` | 0x02 | `rd = rt >> shamt` | Logical shift right |
| `sra` | 0x03 | `rd = rt >>> shamt` | Arithmetic shift right |
| `sllv` | 0x04 | `rd = rt << rs[4:0]` | Variable logical shift left |
| `srlv` | 0x06 | `rd = rt >> rs[4:0]` | Variable logical shift right |
| `srav` | 0x07 | `rd = rt >>> rs[4:0]` | Variable arithmetic shift right |
| `rol` | 0x1C | `rd = rotate_left(rt, shamt)` | Rotate left |
| `ror` | 0x1D | `rd = rotate_right(rt, shamt)` | Rotate right |
| `slt` | 0x2A | `rd = (rs < rt) ? 1 : 0` | Set less than (signed) |
| `sltu` | 0x2B | `rd = (rs < rt) ? 1 : 0` | Set less than (unsigned) |
| `jr` | 0x08 | `PC = rs` | Jump register |
| `jalr` | 0x09 | `$ra = PC+4; PC = rs` | Jump and link register |
| `enc` | 0x30 | `rd = encrypt(alu_result)` | Encrypt data |
| `dec` | 0x31 | `rd = decrypt(alu_result)` | Decrypt data |

### I-Type Instructions
| Instruction | Opcode | Operation | Description |
|-------------|--------|-----------|-------------|
| `addi` | 0x08 | `rt = rs + sign_ext(imm)` | Add immediate |
| `andi` | 0x0C | `rt = rs & zero_ext(imm)` | AND immediate |
| `ori` | 0x0D | `rt = rs \| zero_ext(imm)` | OR immediate |
| `xori` | 0x0E | `rt = rs ^ zero_ext(imm)` | XOR immediate |
| `slti` | 0x0A | `rt = (rs < sign_ext(imm)) ? 1 : 0` | Set less than immediate |
| `sltiu` | 0x0B | `rt = (rs < sign_ext(imm)) ? 1 : 0` | Set less than immediate unsigned |
| `lw` | 0x23 | `rt = MEM[rs + sign_ext(imm)]` | Load word |
| `sw` | 0x2B | `MEM[rs + sign_ext(imm)] = rt` | Store word |
| `beq` | 0x04 | `if (rs == rt) PC += sign_ext(imm) << 2` | Branch if equal |
| `bne` | 0x05 | `if (rs != rt) PC += sign_ext(imm) << 2` | Branch if not equal |
| `bltz` | 0x01 | `if (rs < 0) PC += sign_ext(imm) << 2` | Branch if less than zero |
| `bgez` | 0x01 | `if (rs >= 0) PC += sign_ext(imm) << 2` | Branch if greater/equal zero |

### J-Type Instructions
| Instruction | Opcode | Operation | Description |
|-------------|--------|-----------|-------------|
| `j` | 0x02 | `PC = {PC[31:28], addr, 2'b00}` | Jump |
| `jal` | 0x03 | `$ra = PC+4; PC = {PC[31:28], addr, 2'b00}` | Jump and link |

## Control Flow

### Sequential Execution
- PC increments by 4 each cycle for sequential instructions
- Next PC = current PC + 4

### Branch Execution
- Branch target = PC + 4 + (sign_extended_immediate << 2)
- Branch taken when ALU Zero flag is set for `beq` operations
- PC source multiplexer selects branch target when branch is taken

### Jump Execution
- Jump target uses concatenation: `{PC[31:28], instruction[25:0], 2'b00}`
- Jump-and-link instructions save return address (PC+4) to $ra

## Memory Interface

### Instruction Memory
- Word-addressed, read-only access
- Provides 32-bit instructions based on PC value
- Supports program loading via `$readmemh`

### Data Memory
- Word-addressed read/write access
- Load operations: data flows from memory to register file
- Store operations: data flows from register file to memory
- Address calculated by ALU (base + offset)

## Debug Interface

The module provides four debug outputs for monitoring processor state:
- **pc_debug**: Current program counter value
- **instruction_debug**: Current instruction being executed
- **alu_result_debug**: Result from ALU operation
- **mem_data_debug**: Data read from memory

## Usage Example

```verilog
MIPS_CPU cpu_inst (
    .clk(system_clock),
    .reset(system_reset),
    .pc_debug(current_pc),
    .instruction_debug(current_instruction),
    .alu_result_debug(alu_output),
    .mem_data_debug(memory_data)
);
```

## Implementation Notes

### Clock Cycle Timing
- All operations complete within a single clock cycle
- Critical path includes: instruction fetch → control decode → register read → ALU operation → memory access → register write
- Clock frequency limited by longest combinational path

### Reset Behavior
- Synchronous reset initializes PC to 0
- Register file is cleared on reset
- Memory contents preserved across reset

### Special Features
- **Crypto Unit**: Provides XOR-based encryption/decryption with fixed key `0xDEADB3EF`
- **Shift Operations**: Support both immediate and variable shift amounts
- **Branch Prediction**: None (single-cycle implementation)

### Limitations
- Single-cycle design limits maximum clock frequency
- No pipeline hazard handling (not applicable)
- No cache memory (direct memory access)
- Fixed instruction and data memory sizes

## Related Modules

This module instantiates and connects the following submodules:
- [`ControlUnit`](ControlUnit.md) - Instruction decode and control signal generation
- [`ALU`](ALU.md) - Arithmetic and logic operations
- [`RegisterFile`](GPRF.md) - General-purpose register storage
- [`InstMem`](InstMem.md) - Instruction memory
- [`DataMem`](DataMem.md) - Data memory
- [`ImmExt`](ImmExt.md) - Immediate value extension
- [`Crypt`](Crypt.md) - Encryption/decryption unit
- [`Mux41`](Mux.md) - 4:1 multiplexers for data selection
- `Program_Counter` - Program counter register
