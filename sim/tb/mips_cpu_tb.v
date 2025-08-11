`timescale 1ns/1ps

module mips_cpu_tb(
  output wire tb_reset
);

  // Clock and reset
  reg clk = 0;
  reg rst = 1;
  assign tb_reset = rst;

  // debug signals
  wire [31:0] debug_pc;
  wire [31:0] debug_instr;
  wire [31:0] debug_alu_result;
  wire [31:0] debug_mem_data;

  // DUT
MIPS_CPU dut (
  .clk(clk),
  .reset(rst),
  .pc_debug(debug_pc),
  .instruction_debug(debug_instr),
  .alu_result_debug(debug_alu_result),
  .mem_data_debug(debug_mem_data)
);

  // 100 MHz clock
  always #5 clk = ~clk;

  // VCD dump
  initial begin
    $dumpfile("build/mips_cpu_tb.vcd");
    $dumpvars(0, mips_cpu_tb);
  end

  // Reset and run
  integer i;
  initial begin
    // Hold reset a few cycles (set rst=1 before connecting to DUT)
    repeat (3) @(posedge clk);
    rst = 0;

    // Run for N cycles
    for (i = 0; i < 50; i = i + 1) begin
      @(posedge clk);
      $display("PC=%08x INSTR=%08x", debug_pc, debug_instr);
    end

        $display("Done");
        $finish;
      end
    endmodule