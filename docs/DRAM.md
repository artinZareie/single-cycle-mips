# DRAM (Dynamic Random Access Memory)

The DRAM module simulates a 4GiB, byte-addressable, little-endian, square 2D memory array (65536x65536). It provides a single combinational read port and a single write port (write occurs on the falling edge of the clock). This module is intended for simulation and connection to a motherboard bus.

## Features
- 4GiB total capacity (2^32 bytes) (customizable)
- Byte-addressable (8 bits per cell) (customizable)
- Square 2D array: 65536 rows x 65536 columns (customizable)
- Combinational (asynchronous) read
- Synchronous write on the falling edge of the clock
- Synchronous reset (zeroes all memory)

## Ports
- **clk**: Clock input
- **rst**: Synchronous reset (zeroes all memory)
- **addr**: 32-bit byte address
- **wdata**: 8-bit data to write
- **write_enable**: Write enable signal
- **rdata**: 8-bit output data (read)

## Example Usage
```
DRAM dram (
    .clk(clk),
    .rst(rst),
    .addr(address),
    .wdata(write_data),
    .write_enable(we),
    .rdata(read_data)
);
```

## Notes
- Address is split: row = addr[31:16], col = addr[15:0]
- Reads are combinational; writes occur on the falling edge of the clock when write_enable is high.
- Reset zeroes the entire memory array.
- For simulation only; not synthesizable for real hardware due to size.
