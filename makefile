VERILOG_COMPILER = iverilog
VFLAGS = -o build/sim.out

SIMULATOR = vvp
WAVEFORM_VIEWER = gtkwave

RTL_FILES = $(shell find ./src/core -name "*.v") src/cpu_top_level.v
TB_FILES = $(shell find ./sim/tb -name "*.v")

# GPRF specific files
GPRF_RTL = src/core/reg_file.v
GPRF_TB = sim/tb/gprf_tb.v

# ALU specific files
ALU_RTL = src/core/alu.v
ALU_TB = sim/tb/alu_tb.v

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

wave_sim: sim
	$(WAVEFORM_VIEWER) build/sim.vcd &

clean:
	rm -rf build/

.PHONY: all sim clean test_gprf wave_gprf wave_sim test_alu wave_alu
