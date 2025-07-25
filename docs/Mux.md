# Multiplexer Modules Documentation

## Mux21 (2-to-1 Multiplexer)

### Overview
The Mux21 module is a 2-to-1 multiplexer that selects one of two 32-bit inputs based on a 1-bit control signal.

### Ports
| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| a    | Input     | 32    | Input 0 |
| b    | Input     | 32    | Input 1 |
| sel  | Input     | 1     | Select signal |
| out  | Output    | 32    | Selected output |

### Functionality
- When `sel = 0`: `out = a`
- When `sel = 1`: `out = b`

## Mux41 (4-to-1 Multiplexer)

### Overview
The Mux41 module is a 4-to-1 multiplexer that selects one of four 32-bit inputs based on a 2-bit control signal.

### Ports
| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| a    | Input     | 32    | Input 0 |
| b    | Input     | 32    | Input 1 |
| c    | Input     | 32    | Input 2 |
| d    | Input     | 32    | Input 3 |
| sel  | Input     | 2     | Select signal |
| out  | Output    | 32    | Selected output |

### Functionality
- When `sel = 2'b00`: `out = a`
- When `sel = 2'b01`: `out = b`
- When `sel = 2'b10`: `out = c`
- When `sel = 2'b11`: `out = d`