/**
 * @file src/control_unit.v
 * @MIPS processor implementation
 * @author Artin Zarei | Mohsen Mirzaei
 */

module MIPS_CPU(
    input wire clk,
    input wire reset,

    output wire [31:0] pc_debug,
    output wire [31:0] instruction_debug,
    output wire [31:0] alu_result_debug,
    output wire [31:0] mem_data_debug
);

wire [31:0] next_pc;
wire [31:0] pc;
wire [31:0] instruction;

wire [ 4:0] address_A;
wire [ 4:0] address_B;
wire [ 4:0] address_W;
wire [31:0] write_data;
wire        rf_write_enable;
wire [31:0] read_data_A;
wire [31:0] read_data_B;

wire [1:0] pc_src_sel;
wire       branch_ctrl;
wire       jump_ctrl;

ControlUnit control_unit_inst (
    .opcode(instruction[31:26]),
    .funct(instruction[5:0]),

        .Branch(branch_ctrl),
        .Jump(jump_ctrl),

    .MemRead(),
    .MemWrite(mem_write_enable),
    .RegWriteSrc(rf_src_sel),

    .RegWrite(rf_write_enable),
    .RegDst(reg_dst_sel),

    .ALUOp(alu_op),
    .ALUSrc(alu_src2_sel),

    .SignExtend(is_signed)
);

// PC address calculations
wire [31:0] pc_plus_4;
wire [31:0] jump_addr;
wire [31:0] branch_addr;
assign pc_plus_4 = pc + 32'd4;
assign jump_addr = {pc[31:28], instruction[25:0], 2'b00};
assign branch_addr = pc_plus_4 + (imm_ext_out << 2);

Mux41 mux41_inst_pc (
    .a(pc_plus_4),
    .b(branch_addr),
    .c(jump_addr),
    .d(32'b0),
    .sel(pc_src_sel),
    .out(next_pc)
);


Program_Counter pc_inst (
    .clk(clk),
    .reset(reset),
    .next_pc(next_pc),
    .pc(pc)
);


InstMem instmem_inst (
    .clk(clk),
    .addr(pc),
    .rdata(instruction)
);

// Decode register addresses from instruction
assign address_A = instruction[25:21]; // rs
assign address_B = instruction[20:16]; // rt

wire [31:0] crypt_out;

// Crypto unit (XOR-based)
Crypt crypt_unit_inst (
    .data_in(alu_result),
    .key(32'hDEADB3EF),
    .data_out(crypt_out)
);

wire [1:0] rf_src_sel;

Mux41 mux41_inst_rf_src (
    .a(alu_result),
    .b(mem_data),
    .c(pc_plus_4),
    .d(crypt_out),
    .sel(rf_src_sel),
    .out(write_data)
);

wire [1:0] reg_dst_sel;
// Destination register: rt (I-type) vs rd (R-type)
assign address_W = reg_dst_sel[0] ? instruction[15:11] : instruction[20:16];

RegisterFile rf_inst (
    .clk(clk),
    .rst(reset),
    .address_A(address_A),
    .address_B(address_B),
    .address_W(address_W),
    .write_data(write_data),
    .write_enable(rf_write_enable),
    .reg_A(read_data_A),
    .reg_B(read_data_B)
);

wire [31:0] imm_ext_out;
wire        is_signed;

ImmExt imm_ext_inst (
    .immediate(instruction[15:0]),
    .is_signed(is_signed),
    .imm_ext(imm_ext_out)
);

wire        alu_src2_sel;
wire [31:0] mux21_inst_1_out;

Mux21 mux21_inst_1 (
    .a(read_data_B),
    .b(imm_ext_out),
    .sel(alu_src2_sel),
    .out(mux21_inst_1_out)
);

wire [3:0]  alu_op;
wire [31:0] alu_result;
wire        alu_zero;

ALU alu_inst (
    .A(read_data_A),
    .B(mux21_inst_1_out),
    .ALUControl(alu_op),
    .ALUResult(alu_result),
    .Zero(alu_zero)
);

// Branch taken when beq control is high and ALU Zero is set
wire branch_taken = branch_ctrl & alu_zero;
assign pc_src_sel = {jump_ctrl, branch_taken};


wire mem_write_enable;
wire [31:0] mem_data;

DataMem data_mem_inst (
    .addr(alu_result),
    .clk(clk),
    .we(mem_write_enable),
    .wdata(read_data_B),
    .rdata(mem_data)
);




// Debug outputs
assign pc_debug = pc;
assign instruction_debug = instruction;
assign alu_result_debug = alu_result;
assign mem_data_debug = mem_data;

endmodule