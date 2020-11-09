.SUFFIXES: .v .vcd

# the program to be read into the instruction memory
PROG = sumtwo
TEXT = ../samples/${PROG}.text
DATA = ../samples/${PROG}.data

# memory and register dump
MEMDUMP = memory.dump
REGDUMP = registers.dump
DUMP = ${MEMDUMP} ${REGDUMP}

# where are the files defining bus sizes, opcode bitmasks, etc
INCLUDE = ../include

# each verilog source file should contain one module
# and should be named as the module name
MAIN = datapath
SRCS = ${MAIN}.v \
       ../modules/controlunit.v \
       ../modules/alu.v \
       ../modules/branchcontrol.v \
       ../modules/flagsreg.v \
       ../modules/memdata.v \
       ../modules/memprog.v \
       ../modules/mov.v \
       ../modules/programcounter.v \
       ../modules/registerfile.v \
       ../modules/signextension.v

all: sim
sim: testbench.vcd
rtl: netlist.png

# generate the testbench module
testbench.v: ${SRCS}
	../tools/tbgen -v incdir=${INCLUDE} \
	               -v dumplevel=3 \
	               dump:regfile.registers:${REGDUMP} \
	               dump:memdata.data:${MEMDUMP} \
	               ${MAIN}.v \
	               >testbench.v

# simulate the waveform file from the testbench
testbench.vcd: testbench.v ${TEXT}
	iverilog -DTEXTFILE=\"${TEXT}\" -DDATAFILE=\"${DATA}\" \
	         -I${INCLUDE} -s testbench -o testbench testbench.v ${SRCS}
	vvp testbench </dev/null
	rm testbench

# draw the rtl netlist png file
netlist.png: ${SRCS}
	yosys -p "read_verilog -DTEXTFILE=\"${TEXT}\" -DDATAFILE=\"${DATA}\" -I${INCLUDE} ${SRCS}; \
	hierarchy -check; \
	show -stretch -format png -prefix ./netlist ${MAIN}"

clean:
	-rm testbench* netlist.* ${TEXT} ${DATA} ${DUMP}

.PHONY: all sim rtl clean
