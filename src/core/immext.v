/*
 * @file src/core/immext.v
 * @author Artin Zarei/Mohsen Mirzaei
 * @brief signed and unsigned extension.
 */

module ImmExt (
input wire [15:0] immediate,
input wire is_signed,
output wire [31:0] imm_ext
);

assign imm_ext = is_signed ? {{16{immediate[15]}}, immediate} : {16'b0, immediate};

endmodule
