# Crypt Module

The Crypt module is a combinational circuit that provides symmetric XOR-based encryption and decryption functionality for the MIPS processor. It implements a simple cryptographic operation using the XOR bitwise operation.

## Ports
- **data_in**: 32-bit input data to be encrypted or decrypted. Since the algorithm works symmetrically, there's no difference.
- **key**: 32-bit encryption/decryption key.
- **data_out**: 32-bit result of XOR operation between data_in and key.

## Functionality
The module performs a bitwise XOR operation between the input data and the key:
```verilog
assign data_out = data_in ^ key;
```

### Symmetric Encryption
Since XOR is its own inverse operation, applying the same key twice returns the original data:
- Encrypt: `encrypted = data XOR key`
- Decrypt: `original = encrypted XOR key`

## Example Usage
```verilog
Crypt crypto_unit (
    .data_in(plaintext),
    .key(encryption_key),
    .data_out(ciphertext)
);
```

## Testing
- **Test Vectors**: `sim/stimuli/crypt_ports.csv`
- **Testbench**: `sim/tb/crypt_tb.v`
- **Run Tests**: `make test_crypt`
- **View Waveforms**: `make wave_crypt`

## Notes
- Combinational logic (no clock required)
- Same key used for both encryption and decryption
- Minimal hardware requirements (32 XOR gates)
- Single cycle operation
