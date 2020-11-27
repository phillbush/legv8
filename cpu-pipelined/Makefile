# the variable PROG must be set to a program name in ../samples

# the program to be read into the instruction memory
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
       ifid.v \
       idex.v \
       exmem.v \
       memwb.v \
       forward.v \
       hazard.v \
       ../modules/alu.v \
       ../modules/branchcontrol.v \
       ../modules/controlunit.v \
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
	               -v timeunit=ps \
	               -v duration=1000 \
	               dump:registerfile.registers:${REGDUMP} \
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
	-rm testbench* netlist.* ${DUMP}

.PHONY: all sim rtl clean
