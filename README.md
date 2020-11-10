LEGv8
=====

This repository contains two implementations of a LEGv8 CPU;
it also contains some tools written in AWK used to test the CPU:
a simple LEGv8 assembler and a verilog testbench generator.
It is the final project of the Computer Organization and Architecture
course of the Computer Science department of the University of Brasilia.

LEGv8 is a simple subset of the ARMv8 AArch64 architecture;
it is a 64-bit architecture that uses 32-bit instructions.
It has 32 registers, each 64-bits wide, (one of them always zero).
To simplify the design, this CPU uses the Harvard memory architecture;
this architecture uses two memories: one for the program itself (the
program memory) and another for the data the program uses (the data memory).
It differs from the Von Neumann architecture in which there is a single memory.

All files are in public domain.


## FILES

* `CPU-pipelined`:   A pipelined implementation of a LEGv8 CPU.
* `CPU-singlecycle`: A single-cycle implementation of a LEGv8 CPU.
* `include`:         Headers defining constants such as bus sizes and opcodes.
* `modules`:         Modules shared by all implementations.
* `samples`:         A sample program written in LEGv8 assembly.
* `tools`:           AWK tools (an assembler and a testbench generator).


## USAGE

**Step 1: Assemble the program.**
First, to test a CPU, a program should be assembled and load into the memory.

The directory `samples/` contains simple sample programs that can be used.
To assemble them, use the AWK assembler located in `tools/asm`.
For example, the following command assembles the program sumtwo.s,
which sum the first two values in memory into the register X0.

	$ cd samples
	$ ../tools/asm sumtwo.s

This command generates two files: sumtwo.text and sumtwo.data.
sumtwo.text contains the machine code of the program instructions.
sumtwo.data contains the raw data used by the program.

To automate the process, the Makefile in the directory `samples/`
assembles all programs and generate both files for each of them.

	$ cd samples
	$ make

**Step 2: Generate the testbench.**
To test the CPU, a testbench should be generated to set the clock the CPU uses.

The directory `cpu-singlecycle/` contains the datapath for a single-cycle CPU.
The datapath is the main module of the CPU, that instantiate all other modules.
In this directory, run the testbench generator at `tools/tbgen` to generate a
testbench for this CPU.  The following command do this, but do not run it yet,
we'll improve this command with some arguments later.

	$ cd cpu-singlecycle
	$ ../tools/tbgen datapath.v > testbench.v

This command will fail, since the datapath module needs some data in
files in the directory ../include.  To specify this directory, we need
to add the following argument:

	-v incdir=../include

This command generates a file `testbench.v` that, when simulated with iverilog(1),
will create a file called `testbench.vcd` containing the waveforms of the CPU.
But this waveform is useless, as it only shows the waves for the two CPU inputs,
which are the clock and the reset signals.  To dump waveforms for more signals,
we need to set the dumplevel to 3: thus we will dump the signals of the testbench
itself, the module under test (datapath.v) and the modules instanciated by the
module under test.  The following argument do this

	-v dumplevel=3

In addition to the waveforms of the signals of the CPU, we can dump the contents
of the data memory and the registers of the CPU at the end of the simulation.
The contents of the data memory are in the array `memdata.data`, and
the contents of the registers are in the array `registerfile.registers`.
The following arguments for `tools/tbgen` dump the contents of the data memory
into the file `memory.dump` and the contents of the registers into the file
`registers.dump`.

	dump:registerfile.registers:registers.dump \
	dump:memdata.data:memory.dump

Assembling all arguments, we got the following command.

	$ cd cpu-singlecycle
	$ ../tools/tbgen -v incdir=../include \
	                 -v dumplevel=3 \
	                 dump:registerfile.registers:registers.dump \
	                 dump:memdata.data:memory.dump \
	                 datapath.v \
	                 >testbench.v

To automate this step, the Makefile in the directory `cpu-singlecycle/`
can generate the testbench for the datapath with the following command.

	$ cd cpu-singlecycle
	$ make testbench.v

**Step 3: Run the simulation.**
To run the simulation, we must first run iverilog(1) to compile the sources
of the datapath and the modules used by it (located at `../modules`).  Then,
run vvp(1) to do the simulation and generate the file `testbench.vcd`, which
contains the waveforms; `registers.dump`, which contains the contents of the
registers; and `memory.dump`, which contains the contents of the registers.
The following commands do it, it will generate the file `testbench`, which we
can delete.  But don't run these commands yet, as they will fail.

	$ cd cpu-singlecycle
	$ iverilog -s testbench -o testbench testbench.v datapth.v ../modules/*.v
	$ vvp testbench </dev/null
	$ rm testbench

This command will fail because again we haven't specified the directory
containing the files to include.  This command will also fail because we
haven't defined the contents of the memories.  We must define `TEXTFILE`
to the file containing the contents of the program memory, and `DATAFILE`
to the file containing the contents of the data memory.  Remember that we
have generated those files in the first step, by assembling the program we
are testing.  The following command do all of this.

	$ cd cpu-singlecycle
	$ iverilog -DTEXTFILE=\"../samples/sumtwo.text\" \
	           -DDATAFILE=\"../samples/sumtwo.data\" \
	           -I../includes -s testbench -o testbench \
	           testbench.v ../modules/*.v
	$ vvp testbench </dev/null
	$ rm testbench

To automate this step, the Makefile in the directory `cpu-singlecycle/`
can run the simulation with the following command.

	$ cd cpu-singlecycle
	$ make sim


**Step 4: Check the results of the simulation.**
To check the waveform generated by the simulation, use the program gtkwave(1)
on the file `testbench.vcd`.  To check the contents of the registers and the
data memory, open the files `memory.dump` and `registers.dump` with your
favorite text editor.  Note that the file `memory.dump` contains one byte
per line; while the file `registers.dump` contain one register (8 bytes)
per line.

**Step 5: Check the RTL netlist.**
To view the RTL netlist of the datapath (or any other module), we can use yosys(1).

The following command generates the file `netlist.png` with the RTL
netlist of the datapath module.  Note that we also need to define
`TEXTFILE`, `DATAFILE` and declare the include directory.

	$ yosys -p "read_verilog -DTEXTFILE=\"../samples/sumtwo.text\" \
	            -DDATAFILE=\"../samples/sumtwo.data\" \
	            -I../include \
	            datapath.v ../modules/*; \
	            hierarchy -check; \
	            show -stretch -format png -prefix ./netlist datapath"

To automate this step, the Makefile in the directory `cpu-singlecycle/`
can synthesizde the rtl netlist with the following command.

	$ cd cpu-singlecycle
	$ make rtl


**Notes.**
To run the simulation with another program, replace `sumtwo` in the
Makefiles with the program you assembled.  To run the simulation with
another CPU, replace the `cpu-singlecycle` directory with the directory
of CPU you want to test.


## INSTRUCTIONS

Check the directories `cpu-*` and `modules` for more information on
the modules that compose the CPUs.

The following is a list of LEGv8 instructions.
Instructions that are checked are the ones supported by this implementation.
Multiplication, division and floating-point operations are not supported yet.

* [x] LSR
* [x] LSL
* [ ] MUL
* [ ] SMULH
* [ ] UMULH
* [ ] SDIV
* [ ] UDIV
* [x] ADD
* [x] SUB
* [x] AND
* [x] ORR
* [x] EOR
* [x] ANDS
* [x] ADDS
* [x] SUBS
* [x] ADDI
* [x] SUBI
* [x] ANDI
* [x] ORRI
* [x] EORI
* [x] ANDIS
* [x] ADDIS
* [x] SUBIS
* [ ] FADDS
* [ ] FADDD
* [ ] FCMPS
* [ ] FCMPD
* [ ] FDIVS
* [ ] FDIVD
* [ ] FMULS
* [ ] FMULD
* [ ] FSUBS
* [ ] FSUBD
* [x] B
* [x] BL
* [x] BR
* [x] CBZ
* [x] CBNZ
* [x] B.EQ
* [x] B.NE
* [x] B.LT
* [x] B.LE
* [x] B.GT
* [x] B.GE
* [x] B.LO
* [x] B.LS
* [x] B.HI
* [x] B.HS
* [x] B.MI
* [x] B.PL
* [x] B.VS
* [x] B.VC
* [ ] LDURB
* [ ] LDURH
* [ ] LDURSW
* [x] LDUR
* [ ] LDXR
* [ ] STURB
* [ ] STURH
* [ ] STURW
* [x] STUR
* [ ] STXR
* [ ] LDURS
* [ ] LDURD
* [ ] STURS
* [ ] STURD
* [x] MOVK
* [x] MOVZ

The following is a list of pseudo instructions supported by the assembler.

* [x] MOV
* [x] CMP
* [x] CMPI
* [x] LDA


## SEE ALSO

Computer Organization and Design: The Hardware/Software Interface ARM Edition
by D. Patterson and J. Hennessy,
Morgan Kaufmann, 2016.
ISBN: 978-012-8017333.
