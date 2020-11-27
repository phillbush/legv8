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
instruction memory) and another for the data the program uses (the data memory).
It differs from the Von Neumann architecture in which there is a single memory.

All files are in public domain.


## FILES

* `CPU-pipelined`:   A pipelined implementation of a LEGv8 CPU, with hazard detection and forwarding.
* `CPU-singlecycle`: A single-cycle implementation of a LEGv8 CPU.
* `include`:         Headers defining constants such as bus sizes and opcodes.
* `modules`:         Modules shared by all implementations.
* `samples`:         Sample programs written in LEGv8 assembly.
* `tools`:           AWK tools (an assembler and a testbench generator).


## USAGE

**Step 1: Assemble the program.**
First, to test a CPU, a program should be assembled in order to be load into its memory.

The directory `samples/` contains simple programs that can be assembled
with the AWK assembler located in `tools/asm`.
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
To test the CPU, a testbench should be generated to pulse the clock the CPU uses.

The directory `cpu-singlecycle/` contains the datapath for a single-cycle CPU.
The datapath is the main module of the CPU, that instantiate all other modules.
In this directory, run the testbench generator at `tools/tbgen` to generate a
testbench for this CPU.  The following command do this, but do not run it yet,
we'll improve this command with some arguments later.

	$ cd cpu-singlecycle
	$ ../tools/tbgen datapath.v > testbench.v

This command will fail, since the datapath module needs some data in the
files in the directory ../include.  To specify this directory, we need
to add the following argument:

	-v incdir=../include

This command generates a file `testbench.v` that, when simulated,
will create a file called `testbench.vcd` containing the waveforms of the CPU.
But this waveform is useless, it only shows waves for the inputs controlled by the testbench,
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
run vvp(1) to do the simulation and generate the files `testbench.vcd` (which
contains the waveforms), `registers.dump` (which contains the contents of the
registers) and `memory.dump` (which contains the contents of the registers).
The following commands do it, it will generate the file `testbench`, which we
can delete after running vvp(1).
But don't run these commands yet, as they will fail.

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
can run the simulation with the following command.  We just need to set
the variable `PROG` to point to the correct program and make `sim` (simulation).

	$ cd cpu-singlecycle
	$ make PROG=sumtwo sim


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
	$ make PROG=sumtwo rtl


**Notes.**
To run the simulation with another program, replace `sumtwo` in the
`make` invocations with the program you assembled.  To run the simulation with
another CPU, go to a directory other than `cpu-singlecycle`.


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


## IMPLEMENTATION

A simpler LEGv8 processor is described at the Computer Organization and Design book.
There are some differences between the processor implemented here and the one described in the book.

* This implementation does not use an ALU Control Unit separated from the Main Control Unit.
  Instead, the ALU Control signal is embedded in the Main Control Unit.

* This implementation does not use the Shift Left 2 module separate from the Sign-Extend module.
  Instead, the Shift Left 2 operation is done by the Sign-Extend module.

* This implementation deals with all flags and flag-based branch instructions,
  while the book's implementation only deals with the `zero` flag.
  There is a Flags Register module which stores flags.
  The ALU outputs a bus of flags to be set,
  and the Control Unit outputs a control signal, called `SETFLAGS`, specifying whether the
  flags output from the ALU should be saved on the Flags register.

* This implementation deals with `MOV` instructions.
  For this, it is needed a new module, called the MOV Unit module.

* This implementation of the pipelined CPU decides whether to branch on the write-back stage.
  The book, however, decides whether to branch one stage earlier, on the memory access stage.
  It's done later here because we need the flags read from the Flags Register
  (which is read on the memory access stage) in order to decide whether to branch.

* The ALU control signal uses 6 bits rather than the 3 bits on the book.
  The two first bits specifies whether to invert the two ALU operands;
  the two following bits specifies whether and to which direction shift the result;
  and the two last bits specifies one of the four operations to be executed.

* The meaning of the bits of the control signal output by the Forwarding Unit
  in this implementation is different from the book.
  (See `include/forward.vh`).

In addition, the Control Unit implemented here outputs more control signals than the one on the book:

* This implementation adds the control sign `SETFLAGS`.
  This control signal decides whether to save the flags output from the ALU to the Flags Register.

* This implementation adds the control signal `REG1LOC`.
  This control signal decides whether the first register read from the Register File
  is the register zero (`XZR`) or the register got from the instruction (`Rn`).
  This is required because this ALU does no “Return B” operation;
  instead, to return the second operand, we need to select the OR operation
  between the given value (the second operand) and the contents of the `XZR` register,
  returning thus the second operand.

* This implementation uses a 2-bit control signal called `REGSRC`
  to specify the source of the data to be written into the register on the write-back stage.
  In the book, there is only one control signal to do that: the `MEMTOREG` control sign,
  which decides whether the data to be write on the registers comes from the memory, or from the ALU.
  Since here this data can come from four places we need a two-bit control signal.
  These four places are:
  the ALU result (for arithmetic instructions);
  the MOV result (for moving instructions);
  the memory (for `STUR` instructions);
  or the PC (for the `BL` instruction).


## TODO

* [ ] Decrease the number of bits of the ALU contrl signal from 6 to 5.
* [x] Reuse the ALU to add the PC to the extended signal (and thus remove `modules/pcadder.v`).
* [ ] Remove the need for passing the opcode from the ID stage to later stages
      (maybe by increasing the number of control signals?).
* [x] Add a mux from both `alures` and `movres` to a single `res`.
* [ ] Remove disassembling of control signal in cpu-singlecycle.


## SEE ALSO

Computer Organization and Design: The Hardware/Software Interface ARM Edition
by D. Patterson and J. Hennessy,
Morgan Kaufmann, 2016.
ISBN: 978-012-8017333.
