# ALU (Arithmetic Logic Unit)

The ALU is a combinational module that performs arithmetic and logic operations in the MIPS processor. It supports all available operations in a standard MIPS processor (reference is inside `refs/mips-ref.pdf`).

## Supported Operations
| ALUControl | Operation                | Description                                 |
|------------|--------------------------|---------------------------------------------|
| 0          | ADD (A + B)              | Addition                                    |
| 1          | SUB (A - B)              | Subtraction                                 |
| 2          | MUL (A * B)              | Multiplication                              |
| 3          | AND (A & B)              | Bitwise AND                                 |
| 4          | XOR (A ^ B)              | Bitwise XOR                                 |
| 5          | OR  (A \| B)             | Bitwise OR                                  |
| 6          | NOR (~(A | B))           | Bitwise NOR (on A, B)                       |
| 7          | NEG (-A)                 | Two's complement negation of A              |
| 8          | SLL (A << B[4:0])        | Logical shift left                          |
| 9          | SRL (A >> B[4:0])        | Logical shift right                         |
| 10         | SLA (A <<< B[4:0])       | Arithmetic shift left (same as logical)     |
| 11         | SRA (A >>> B[4:0])       | Arithmetic shift right                      |
| 12         | ROL (A rotated left)     | Rotate left by B[4:0] bits                  |
| 13         | ROR (A rotated right)    | Rotate right by B[4:0] bits                 |
| 14         | SLT (A < B, signed)      | Set to 1 if A < B (signed), else 0          |
| 15         | SLTU (A < B, unsigned)   | Set to 1 if A < B (unsigned), else 0        |

## Ports
- **A**: 32-bit input operand
- **B**: 32-bit input operand
- **ALUControl**: 4-bit control signal selecting the operation
- **ALUResult**: 32-bit output result
- **Zero**: Output flag, 1 if ALUResult is zero

## Example Usage
```
ALU uut (
    .A(a),
    .B(b),
    .ALUControl(ctrl),
    .ALUResult(result),
    .Zero(zero)
);
```

## Notes
- Shifts and rotates use the lower 5 bits of B as the shift amount.
- SLT and SLTU output 1 or 0 in the least significant bit; the rest are zero.
- The Zero flag is set if the result is exactly zero.
