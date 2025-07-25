/**
 * @file src/helpers/mux21.v
 * @brief 2-to-1 multiplexer module.
 * @author Artin Zarei/Mohsen Mirzaei
 */

module Mux21 (
input wire [31:0] a,
input wire [31:0] b,
input wire sel,
output wire [31:0] out
);

assign out = sel ? b : a;

endmodule
