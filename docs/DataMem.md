# Data Memory (DataMem)

## Overview
Data Memory module provides read/write access to data storage. It's a simple wrapper around the DRAM module that passes through all control signals.

## Interface
```verilog
module DataMem (
    input  wire [31:0] addr,   // Address input
    input  wire        clk,    // Clock signal
    input  wire        we,     // Write enable
    input  wire [31:0] wdata,  // Write data input
    output wire [31:0] rdata   // Read data output
);
```

## Functionality
- Read and write data access
- Uses DRAM internally with direct signal pass-through
- Write enable controls write operations
- Synchronous operation on clock edge
