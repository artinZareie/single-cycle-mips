# Instruction Memory (InstMem)

## Overview
Instruction Memory module provides read-only access to instruction storage. It's a simple wrapper around the DRAM module with write functionality disabled.

## Interface
```verilog
module InstMem (
    input  wire [31:0] addr,   // Address input
    input  wire        clk,    // Clock signal  
    output wire [31:0] rdata   // Instruction output
);
```

## Functionality
- Read-only instruction access
- Uses DRAM internally with write_enable tied to 0
- Synchronous operation on clock edge
