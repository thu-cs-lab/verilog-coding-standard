VERILOG_SOURCES=$(shell find . -type f -name '*.v')
SYSTEMVERILOG_SOURCES=$(shell find . -type f -name '*.sv')

TARGETS=$(patsubst %,%.blif,$(VERILOG_SOURCES) $(SYSTEMVERILOG_SOURCES))

all: $(TARGETS)

%.blif: %
	yosys -o $@ -S $^

clean:
	rm -rf */*.blif