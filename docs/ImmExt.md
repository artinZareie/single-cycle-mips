# ImmExt Module Documentation

## Overview
The ImmExt (Immediate Extension) module performs sign extension or zero extension of 16-bit immediate values to 32-bit values, commonly used in MIPS processor instruction decoding.

## Module Interface

### Ports
| Port Name  | Direction | Width | Description |
|------------|-----------|-------|-------------|
| immediate  | Input     | 16    | 16-bit immediate value to be extended |
| is_signed  | Input     | 1     | Control signal: 1 for sign extension, 0 for zero extension |
| imm_ext    | Output    | 32    | 32-bit extended immediate value |

## Functionality

### Sign Extension (is_signed = 1)
When `is_signed` is high, the module performs sign extension by replicating the most significant bit (bit 15) of the immediate value to fill the upper 16 bits of the output.

- For positive numbers (MSB = 0): `imm_ext = {16'b0, immediate}`
- For negative numbers (MSB = 1): `imm_ext = {16'b1, immediate}`

### Zero Extension (is_signed = 0)
When `is_signed` is low, the module performs zero extension by filling the upper 16 bits with zeros.

- For all values: `imm_ext = {16'b0, immediate}`

## Implementation
The module uses a conditional assignment operator to select between sign extension and zero extension based on the `is_signed` control signal.

```verilog
assign imm_ext = is_signed ? {{16{immediate[15]}}, immediate} : {16'b0, immediate};
```
