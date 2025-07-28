/**
 * @file src/core/crypt.v
 * Cryptographic module for MIPS processor. Provides basic encryption and decryption functions.
 * @author Artin Zarei | Mohsen Mirzaei
 * @details This module implements a simple XOR-based encryption and decryption mechanism.
 */

module Crypt (
    input  wire [31:0] data_in,  // Input data to be encrypted or decrypted. Since this is a symmetric encryption, the same input is used for both operations.
    input wire [31:0] key,  // Key for encryption/decryption.
    output wire [31:0] data_out  // Output data after encryption or decryption.
);

    assign data_out = data_in ^ key;

endmodule
