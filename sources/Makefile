VERILOG_SOURCES=$(shell find . -type f -name '*.v')
SYSTEMVERILOG_SOURCES=$(shell find . -type f -name '*.sv')

TARGETS=$(patsubst %,%.syn,$(VERILOG_SOURCES) $(SYSTEMVERILOG_SOURCES))

all: $(TARGETS)

%.syn: %
	yosys -b verilog -o $@ -p 'synth_xilinx' $^

clean:
	rm -rf */*.syn