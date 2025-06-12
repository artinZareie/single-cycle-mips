VERILOG_COMPILER = iverilog
VFLAGS = -o build/sim.out

SIMULATOR = vvp

RTL_FILES = $(find . -regex "./src/core/.*\.v") src/cpu_top_level.v
TB_FILES = $(wildcard src/tb/*.v)

all: sim

sim: $(RTL_FILES) $(TB_FILES)
	@mkdir -p build
	$(VERILOG_COMPILER) $(VFLAGS) $(RTL_FILES) $(TB_FILES)
	$(SIMULATOR) build/sim.out

clean:
	rm -rf build/

.PHONY: all sim clean
