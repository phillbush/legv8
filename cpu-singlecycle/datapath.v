`include "aluop.vh"
`include "bus.vh"
`include "control.vh"
`include "flags.vh"
`include "movop.vh"
`include "registers.vh"

module datapath(clk, rst);
	input wire clk;                         /* clock */
	input wire rst;                         /* reset */

	/* wires for internal registers */
	wire [`WORDSIZE-1:0] pc;                /* program counter */
	wire [`FLAGSIZE-1:0] flags;             /* alu flags */

	/* the instruction and its parts */
	wire [`INSTSIZE-1:0] instruction;
	wire [`OPCODESIZE-1:0] opcode;
	wire [`REGADDRSIZE-1:0] rm;             /* register M (source 1) */
	wire [`REGADDRSIZE-1:0] rn;             /* register N (source 2) */
	wire [`REGADDRSIZE-1:0] rd;             /* register D (destination) */
	wire [`SHAMTSIZE-1:0] shamt;

	/* word data signals */
	wire [`WORDSIZE-1:0] writereg;          /* data to be written on the registers */
	wire [`WORDSIZE-1:0] readreg1;          /* data of 1st register read */
	wire [`WORDSIZE-1:0] readreg2;          /* data of 2nd register read */
	wire [`WORDSIZE-1:0] readmem;           /* data of read from memory */
	wire [`WORDSIZE-1:0] alures;            /* result of the alu */
	wire [`WORDSIZE-1:0] movres;            /* result of the mov module */
	wire [`WORDSIZE-1:0] res;               /* result of the alu/mov */
	wire [`WORDSIZE-1:0] extended;          /* output of sign-extension */

	/* control signals */
	wire branch;            /* whether to branch */
	wire reg1loc;           /* whether 1st register read is Rn or X31 */
	wire reg2loc;           /* whether 2nd register read is Rm or Rd */
	wire memread;           /* whether to write from data memory */
	wire memwrite;          /* whether to write into data memory */
	wire setflags;          /* whether to set flags */
	wire usemov;            /* whether we are using a MOV instruction */
	wire alu1src;           /* whether 1nd ALU operand is first register read or PC */
	wire alu2src;           /* whether 2nd ALU operand is second register read or extension */
	wire regwrite;          /* whether to write on register file */
	wire pctoreg;           /* whether to write PC on register file */
	wire memtoreg;          /* whether to write data read from memory on register file */
	wire [`ALUOPSIZE-1:0] aluop;
	wire [`MOVOPSIZE-1:0] movop;
	wire [`CONTROLSIZE-1:0] control;
	wire [`FLAGSIZE-1:0] flagstoset;

	/* disassemble the instruction */
	assign opcode = instruction[31:21];
	assign rm     = instruction[20:16];
	assign shamt  = instruction[15:10];
	assign rn     = instruction[9:5];
	assign rd     = instruction[4:0];

	/* disassemble the control */
	assign reg1loc = control[`REG1LOC];
	assign reg2loc = control[`REG2LOC];
	assign memread = control[`MEMREAD];
	assign memwrite = control[`MEMWRITE];
	assign setflags = control[`SETFLAGS];
	assign usemov = control[`USEMOV];
	assign alu1src = control[`ALU1SRC];
	assign alu2src = control[`ALU2SRC];
	assign regwrite = control[`REGWRITE];
	assign pctoreg = control[`PCTOREG];
	assign memtoreg = control[`MEMTOREG];

	/* get result from alu/mov */
	assign res = usemov ? movres : alures;

	/* decide which data will be written back on the registers */
	assign writereg = pctoreg ? pc
	                : memtoreg ? readmem
	                : res;

	/* compute program counter at each clock posedge */
	programcounter progcount(clk, rst, 1'b0, branch, res, pc);

	/* get instruction from the address in the program counter */
	memprog memprog(pc, instruction);

	/* set the control signals and the alu operation */
	controlunit controlunit(opcode, control, aluop, movop);

	/* extend the immediate or address in the instruction */
	signextension signextension(instruction, extended);

	/* read and write registers from the register file */
	registerfile registerfile(clk, rst,
	                          (reg1loc ? `XZR : rn),
	                          (reg2loc ? rd : rm),
	                          (pctoreg ? `XLR : rd),
	                          writereg,
	                          regwrite,
	                          readreg1,
	                          readreg2);

	/* how many bits to shift the second alu operand */
	mov mov(readreg2, extended, movop, movres);

	/* the arithmetic-logic unit */
	alu alu((alu1src ? pc : readreg1),
	        (alu2src ? extended : readreg2),
	        shamt,
	        aluop,
	        alures,
	        flagstoset);

	/* set the control signals and the alu operation */
	branchcontrol branchcontrol(opcode, readreg2, rd, flags, branch);

	/* control the flags register */
	flagsregister flagsreg(clk, rst, setflags, flagstoset, flags);

	/* read and write data from/into the memory */
	memdata memdata(clk, rst, res, readreg2, memread, memwrite, readmem);
endmodule
