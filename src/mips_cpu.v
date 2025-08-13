/**
 * @file src/mips_cpu.v
 * @brief Single-cycle MIPS CPU implementation
 * @author Artin Zareie | Mohsen Mirzaei
 */

module MIPS_CPU(
    input wire clk,
    input wire reset,

    output wire [31:0] pc_debug,
    output wire [31:0] instruction_debug,
    output wire [31:0] alu_result_debug,
    output wire [31:0] mem_data_debug
);

// PC-related signals
wire [31:0] next_pc, pc, pc_plus_4, jump_addr, branch_addr;

// Instruction and control signals
wire [31:0] instruction;
wire [1:0] pc_src_sel, rf_src_sel, reg_dst_sel;
wire branch_ctrl, jump_ctrl, rf_write_enable, mem_write_enable;
wire alu_src2_sel, is_signed, shift_op, var_shift;
wire [3:0] alu_op;
wire branch_taken;

// Register file signals
wire [4:0] address_A, address_B, address_W;
wire [31:0] write_data, read_data_A, read_data_B;

// ALU and memory signals
wire [31:0] alu_in_A, alu_in_B, alu_result, imm_ext_out;
wire [31:0] mem_data, crypt_out;
wire alu_zero;

// Control Unit - Generates all control signals
ControlUnit control_unit_inst (
    .opcode(instruction[31:26]),
    .funct(instruction[5:0]),
    .Branch(branch_ctrl),
    .Jump(jump_ctrl),
    .MemRead(/* unused */),
    .MemWrite(mem_write_enable),
    .RegWriteSrc(rf_src_sel),

    .RegWrite(rf_write_enable),
    .RegDst(reg_dst_sel),

    .ALUOp(alu_op),
    .ALUSrc(alu_src2_sel),

    .SignExtend(is_signed),
    .ShiftOp(shift_op),
    .VarShift(var_shift)
);

// PC address calculations
assign pc_plus_4 = pc + 32'd4;
assign jump_addr = {pc[31:28], instruction[25:0], 2'b00};
assign branch_addr = pc_plus_4 + (imm_ext_out << 2);

// PC source selection mux: 00=PC+4, 01=branch, 10=jump, 11=unused
Mux41 pc_mux_inst (
    .a(pc_plus_4),
    .b(branch_addr),
    .c(jump_addr),
    .d(32'b0),
    .sel(pc_src_sel),
    .out(next_pc)
);

// Program Counter
Program_Counter pc_inst (
    .clk(clk),
    .reset(reset),
    .next_pc(next_pc),
    .pc(pc)
);

// Instruction Memory
InstMem imem_inst (
    .clk(clk),
    .addr(pc),
    .rdata(instruction)
);

// Register address selection for shift/rotate operations
// For shift/rotate: A=rt (source), B=shamt (immediate) or rs (variable shift amount)
// For other operations: A=rs, B=rt
assign address_A = (shift_op) ? instruction[20:16] : instruction[25:21]; // rt for shift/rotate, else rs
assign address_B = (shift_op && var_shift) ? instruction[25:21] : instruction[20:16]; // rs for var shift, else rt

// Crypto unit (XOR-based encryption/decryption)
Crypt crypt_inst (
    .data_in(alu_result),
    .key(32'hDEADB3EF),
    .data_out(crypt_out)
);

// Register file write data source selection
Mux41 rf_src_mux_inst (
    .a(alu_result),
    .b(mem_data),
    .c(pc_plus_4),
    .d(crypt_out),
    .sel(rf_src_sel),
    .out(write_data)
);

// Destination register selection: rt (I-type) vs rd (R-type)
assign address_W = reg_dst_sel[0] ? instruction[15:11] : instruction[20:16];

// Register File
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

// Immediate extension
ImmExt imm_ext_inst (
    .immediate(instruction[15:0]),
    .is_signed(is_signed),
    .imm_ext(imm_ext_out)
);

// ALU input A selection (always read_data_A)
assign alu_in_A = read_data_A;

// ALU input B selection: shamt (immediate), rs (variable shift), or rt/immediate
wire [31:0] shamt_extended = {27'b0, instruction[10:6]};
assign alu_in_B = (shift_op && !var_shift) ? shamt_extended :
                  (shift_op && var_shift) ? read_data_B :
                  (alu_src2_sel ? imm_ext_out : read_data_B);

// ALU
ALU alu_inst (
    .A(alu_in_A),
    .B(alu_in_B),
    .ALUControl(alu_op),
    .ALUResult(alu_result),
    .Zero(alu_zero)
);

// Branch taken when beq control is high and ALU Zero is set
assign branch_taken = branch_ctrl & alu_zero;
assign pc_src_sel = {jump_ctrl, branch_taken};

// Data Memory
DataMem dmem_inst (
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