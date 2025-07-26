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

all: sim

sim: $(RTL_FILES) $(TB_FILES)
	@mkdir -p build
	$(VERILOG_COMPILER) $(VFLAGS) $(RTL_FILES) $(TB_FILES)
	$(SIMULATOR) build/sim.out

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

clean:
	rm -rf build/

.PHONY: all sim clean format test_gprf wave_gprf wave_sim test_alu wave_alu test_dram wave_dram test_immext wave_immext test_mux21 wave_mux21 test_mux41 wave_mux41 test_imem wave_imem test_dmem wave_dmem
