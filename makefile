VERILOG_COMPILER = iverilog
VFLAGS = -o build/sim.out

SIMULATOR = vvp
WAVEFORM_VIEWER = gtkwave

RTL_FILES = $(shell find ./src -name "*.v")
TB_FILES = $(shell find ./sim/tb -name "*.v")

# GPRF specific files
GPRF_RTL = src/core/reg_file.v
GPRF_TB = sim/tb/gprf_tb.v

# ALU specific files
ALU_RTL = src/core/alu.v
ALU_TB = sim/tb/alu_tb.v

# DRAM specific files
DRAM_RTL = src/mem/dram.v
DRAM_TB = sim/tb/dram_tb.v

# ImmExt specific files
IMMEXT_RTL = src/core/immext.v
IMMEXT_TB = sim/tb/immext_tb.v

# Mux21 specific files
MUX21_RTL = src/helpers/mux21.v
MUX21_TB = sim/tb/mux21_tb.v

# Mux41 specific files
MUX41_RTL = src/helpers/mux41.v
MUX41_TB = sim/tb/mux41_tb.v

# InstMem specific files
IMEM_RTL = src/mem/imem.v src/mem/dram.v
IMEM_TB = sim/tb/imem_tb.v

# DataMem specific files
DMEM_RTL = src/mem/dmem.v src/mem/dram.v
DMEM_TB = sim/tb/dmem_tb.v

# Crypt specific files
CRYPT_RTL = src/core/crypt.v
CRYPT_TB = sim/tb/crypt_tb.v

# MIPS CPU (top module) specific files
MIPS_CPU_RTL = $(RTL_FILES)
MIPS_CPU_TB = sim/tb/mips_cpu_tb.v

# Dot Product test specific files
DOT_PRODUCT_RTL = $(RTL_FILES)
DOT_PRODUCT_TB = sim/tb/tb_InnerProduct.v

all: sim

sim: $(RTL_FILES) $(TB_FILES)
	@mkdir -p build
	$(VERILOG_COMPILER) $(VFLAGS) $(RTL_FILES) $(TB_FILES)
	$(SIMULATOR) build/sim.out

test_all: test_gprf test_alu test_dram test_immext test_mux21 test_mux41 test_imem test_dmem test_crypt test_mips_cpu test_dot_product
	@echo "All module tests completed!"

# MIPS CPU (Top Module) Test
test_mips_cpu: $(MIPS_CPU_RTL) $(MIPS_CPU_TB)
	@mkdir -p build
	@echo "Testing MIPS CPU (Top Module)..."
	$(VERILOG_COMPILER) -o build/mips_cpu_sim.out $(MIPS_CPU_RTL) $(MIPS_CPU_TB)
	$(SIMULATOR) build/mips_cpu_sim.out

wave_mips_cpu: test_mips_cpu
	$(WAVEFORM_VIEWER) build/mips_cpu_tb.vcd &

# Quick CPU test (alias for convenience)
test_cpu: test_mips_cpu

wave_cpu: wave_mips_cpu

# Dot Product Test
test_dot_product: $(DOT_PRODUCT_RTL) $(DOT_PRODUCT_TB)
	@mkdir -p build
	@echo "Testing Dot Product calculation..."
	$(VERILOG_COMPILER) -o build/dot_product_sim.out $(DOT_PRODUCT_RTL) $(DOT_PRODUCT_TB)
	$(SIMULATOR) build/dot_product_sim.out

wave_dot_product: test_dot_product
	$(WAVEFORM_VIEWER) build/tb_InnerProduct.vcd &

test_gprf: $(GPRF_RTL) $(GPRF_TB)
	@mkdir -p build
	$(VERILOG_COMPILER) -o build/gprf_sim.out $(GPRF_RTL) $(GPRF_TB)
	$(SIMULATOR) build/gprf_sim.out

wave_gprf: test_gprf
	$(WAVEFORM_VIEWER) build/gprf_tb.vcd &

test_alu: $(ALU_RTL) $(ALU_TB)
	@mkdir -p build
	$(VERILOG_COMPILER) -o build/alu_sim.out $(ALU_RTL) $(ALU_TB)
	$(SIMULATOR) build/alu_sim.out

wave_alu: test_alu
	$(WAVEFORM_VIEWER) build/alu_tb.vcd &

test_dram: $(DRAM_RTL) $(DRAM_TB)
	@mkdir -p build
	$(VERILOG_COMPILER) -o build/dram_sim.out $(DRAM_RTL) $(DRAM_TB)
	$(SIMULATOR) build/dram_sim.out

wave_dram: test_dram
	$(WAVEFORM_VIEWER) build/dram_tb.vcd &

test_immext: $(IMMEXT_RTL) $(IMMEXT_TB)
	@mkdir -p build
	$(VERILOG_COMPILER) -o build/immext_sim.out $(IMMEXT_RTL) $(IMMEXT_TB)
	$(SIMULATOR) build/immext_sim.out

wave_immext: test_immext
	$(WAVEFORM_VIEWER) build/immext_tb.vcd &

test_mux21: $(MUX21_RTL) $(MUX21_TB)
	@mkdir -p build
	$(VERILOG_COMPILER) -o build/mux21_sim.out $(MUX21_RTL) $(MUX21_TB)
	$(SIMULATOR) build/mux21_sim.out

wave_mux21: test_mux21
	$(WAVEFORM_VIEWER) build/mux21_tb.vcd &

test_mux41: $(MUX41_RTL) $(MUX41_TB)
	@mkdir -p build
	$(VERILOG_COMPILER) -o build/mux41_sim.out $(MUX41_RTL) $(MUX41_TB)
	$(SIMULATOR) build/mux41_sim.out

wave_mux41: test_mux41
	$(WAVEFORM_VIEWER) build/mux41_tb.vcd &

test_imem: $(IMEM_RTL) $(IMEM_TB)
	@mkdir -p build
	$(VERILOG_COMPILER) -o build/imem_sim.out $(IMEM_RTL) $(IMEM_TB)
	$(SIMULATOR) build/imem_sim.out

wave_imem: test_imem
	$(WAVEFORM_VIEWER) build/imem_tb.vcd &

test_dmem: $(DMEM_RTL) $(DMEM_TB)
	@mkdir -p build
	$(VERILOG_COMPILER) -o build/dmem_sim.out $(DMEM_RTL) $(DMEM_TB)
	$(SIMULATOR) build/dmem_sim.out

wave_dmem: test_dmem
	$(WAVEFORM_VIEWER) build/dmem_tb.vcd &

test_crypt: $(CRYPT_RTL) $(CRYPT_TB)
	@mkdir -p build
	$(VERILOG_COMPILER) -o build/crypt_sim.out $(CRYPT_RTL) $(CRYPT_TB)
	$(SIMULATOR) build/crypt_sim.out

wave_crypt: test_crypt
	$(WAVEFORM_VIEWER) build/crypt_tb.vcd &

wave_sim: sim
	$(WAVEFORM_VIEWER) build/sim.vcd &

format:
	@echo "Formatting Verilog files..."
	find ./src -name "*.v" -exec verible-verilog-format --inplace \
		--indentation_spaces=4 \
		{} \;
	find ./sim -name "*.v" -exec verible-verilog-format --inplace \
		--indentation_spaces=4 \
		{} \;
	@echo "Formatting complete!"

count:
	@echo "Counting Verilog lines..."
	@echo "Source files:"
	@find ./src -name "*.v" -exec wc -l {} + | tail -1
	@echo "Testbench files:"
	@find ./sim -name "*.v" -exec wc -l {} + | tail -1
	@echo "Total:"
	@find ./src ./sim -name "*.v" -exec wc -l {} + | tail -1

# Assembly and test targets
assemble: assembler.py
	@echo "Running assembler..."
	python assembler.py asm-codes/final-test.asm sim/stimuli/assembled.hex clean
	@echo "Assembly complete! Output: sim/stimuli/assembled.hex"

assemble_dot_product: assembler.py
	@echo "Assembling dot product program..."
	python assembler.py asm-codes/dot-product.asm sim/stimuli/assembled.hex clean
	@echo "Dot product assembly complete! Output: sim/stimuli/assembled.hex"

assemble_with_comments: assembler.py
	@echo "Running assembler with full comments..."
	python assembler.py asm-codes/final-test.asm sim/stimuli/assembled_commented.hex full
	@echo "Assembly complete! Output: sim/stimuli/assembled_commented.hex"

# Full test flow: assemble then test CPU
test_full: assemble test_mips_cpu
	@echo "Full test flow completed!"

# Full dot product test flow: assemble dot product then test
test_dot_product_full: assemble_dot_product test_dot_product
	@echo "Full dot product test flow completed!"

clean:
	rm -rf build/

.PHONY: all sim clean format test_all test_gprf wave_gprf wave_sim test_alu wave_alu test_dram wave_dram test_immext wave_immext test_mux21 wave_mux21 test_mux41 wave_mux41 test_imem wave_imem test_dmem wave_dmem test_crypt wave_crypt test_mips_cpu wave_mips_cpu test_cpu wave_cpu test_dot_product wave_dot_product assemble assemble_dot_product assemble_with_comments test_full test_dot_product_full
