/**
 * @file src/helpers/mux41.v
 * @brief 4-to-1 multiplexer module.
 * @author Artin Zarei/Mohsen Mirzaei
 */

module Mux41 (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [31:0] c,
    input  wire [31:0] d,
    input  wire [ 1:0] sel,
    output wire [31:0] out
);

  assign out = (sel == 2'b00) ? a : (sel == 2'b01) ? b : (sel == 2'b10) ? c : d;

endmodule
