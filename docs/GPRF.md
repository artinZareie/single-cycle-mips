# GPRF (General Purpose Register File)

The GPRF is a 32x32 register file. It provides two read ports and one write port, allowing simultaneous reading of two registers and writing to one register @negedge clock cycle.

## Features
- 32 registers, each 32 bits wide
- Synchronous write, asynchronous read
- Register 0 is hardwired to zero (writes to it are ignored)
- Two independent read ports (A, B)
- One write port (W)

## Ports
- **clk**: Clock input
- **rst**: Synchronous reset (clears all registers to zero)
- **address_A**: 5-bit address for read port A
- **address_B**: 5-bit address for read port B
- **address_W**: 5-bit address for write port
- **write_data**: 32-bit data to write
- **write_enable**: Write enable signal
- **reg_A**: 32-bit output from read port A
- **reg_B**: 32-bit output from read port B

## Example Usage
```
RegisterFile gprf (
    .clk(clk),
    .rst(rst),
    .address_A(addr_a),
    .address_B(addr_b),
    .address_W(addr_w),
    .write_data(wdata),
    .write_enable(we),
    .reg_A(data_a),
    .reg_B(data_b)
);
```

## Notes
- Register 0 always reads as zero, regardless of writes.
- Writes occur on the falling edge of the clock when write_enable is high.
- Reads are combinational.
