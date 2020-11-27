`include "aluop.vh"
`include "bus.vh"
`include "control.vh"
`include "flags.vh"
`include "forward.vh"
`include "movop.vh"
`include "registers.vh"

module datapath(clk, rst);
	input wire clk;                         /* clock */
	input wire rst;                         /* reset */

	/* stage counter */
	/*
	 * We need to count stages because the branch wire contains
	 * garbage until the write back stage of the first instruction.
	 * Since the branch is needed by the program counter module, we
	 * need to only input the branch wire to it on the fifth stage
	 * onwards.
	 *
	 * The forwarda, forwardb and hazard, also contain garbage on
	 * earlier stages.
	 */
	reg [`COUNTERSIZE-1:0] stage;

	/* wires for the Hazard Detection Unit */
	wire stall;
	wire nop;

	/* wires for the Forwarding Unit */
	wire [`FORWARDSIZE-1:0] forwarda;
	wire [`FORWARDSIZE-1:0] forwardb;

	/* wires for IF stage */
	wire [`WORDSIZE-1:0] pc;                /* program counter */
	wire [`INSTSIZE-1:0] instruction;

	/* wires for IF-ID register */
	wire ifid_nop;
	wire [`WORDSIZE-1:0] ifid_pc;
	wire [`INSTSIZE-1:0] ifid_instruction;

	/* wires for ID stage */
	wire [`CONTROLSIZE-1:0] control;
	wire [`ALUOPSIZE-1:0] aluop;
	wire [`MOVOPSIZE-1:0] movop;
	wire [`WORDSIZE-1:0] readreg1;          /* value of 1st register read */
	wire [`WORDSIZE-1:0] readreg2;          /* value of 2nd register read */
	wire [`WORDSIZE-1:0] extended;          /* output of sign-extension */
	wire [`OPCODESIZE-1:0] opcode;
	wire [`REGADDRSIZE-1:0] rm;
	wire [`REGADDRSIZE-1:0] rn;
	wire [`REGADDRSIZE-1:0] rd;
	wire [`REGADDRSIZE-1:0] ra;
	wire [`REGADDRSIZE-1:0] rb;
	wire [`SHAMTSIZE-1:0] shamt;

	/* wires for ID-EX register */
	wire idex_nop;
	wire [`IDEX_CONTROLSIZE-1:0] idex_control;
	wire [`OPCODESIZE-1:0] idex_opcode;
	wire [`ALUOPSIZE-1:0] idex_aluop;
	wire [`MOVOPSIZE-1:0] idex_movop;
	wire [`WORDSIZE-1:0] idex_pc;
	wire [`WORDSIZE-1:0] idex_readreg1;
	wire [`WORDSIZE-1:0] idex_readreg2;
	wire [`WORDSIZE-1:0] idex_extended;
	wire [`SHAMTSIZE-1:0] idex_shamt;
	wire [`REGADDRSIZE-1:0] idex_ra;
	wire [`REGADDRSIZE-1:0] idex_rb;
	wire [`REGADDRSIZE-1:0] idex_rd;

	/* wires for EX stage */
	wire exmem_nop;
	wire [`WORDSIZE-1:0] forwardop;         /* forward operand */
	wire [`WORDSIZE-1:0] forwardeda;        /* forwarded operand a */
	wire [`WORDSIZE-1:0] forwardedb;        /* forwarded operand b */
	wire [`WORDSIZE-1:0] movoperand;        /* operand of the mov */
	wire [`WORDSIZE-1:0] alua;              /* operand A of the alu */
	wire [`WORDSIZE-1:0] alub;              /* operand b of the alu */
	wire [`WORDSIZE-1:0] alures;            /* result of the alu */
	wire [`WORDSIZE-1:0] movres;            /* result of the mov module */
	wire [`FLAGSIZE-1:0] flagstoset;

	/* wires for EX-MEM register */
	wire [`EXMEM_CONTROLSIZE-1:0] exmem_control;
	wire [`OPCODESIZE-1:0] exmem_opcode;
	wire [`WORDSIZE-1:0] exmem_pc;
	wire [`WORDSIZE-1:0] exmem_alures;
	wire [`WORDSIZE-1:0] exmem_movres;
	wire [`WORDSIZE-1:0] exmem_readreg2;
	wire [`FLAGSIZE-1:0] exmem_flagstoset;
	wire [`REGADDRSIZE-1:0] exmem_rd;

	/* wires for MEM stage */
	wire [`WORDSIZE-1:0] readmem;
	wire [`FLAGSIZE-1:0] readflags;

	/* wires for MEM-WB register */
	wire [`MEMWB_CONTROLSIZE-1:0] memwb_control;
	wire [`OPCODESIZE-1:0] memwb_opcode;
	wire [`WORDSIZE-1:0] memwb_pc;
	wire [`WORDSIZE-1:0] memwb_readmem;
	wire [`WORDSIZE-1:0] memwb_alures;
	wire [`WORDSIZE-1:0] memwb_movres;
	wire [`WORDSIZE-1:0] memwb_readreg2;
	wire [`FLAGSIZE-1:0] memwb_readflags;
	wire [`REGADDRSIZE-1:0] memwb_rd;

	/* wires for WB stage */
	wire branch;
	wire [`WORDSIZE-1:0] writereg;

	/* initialize the stage counter */
	initial
		stage <= 2'b0;

	/* whether to make a instruction be a no-operation */
	assign nop = stage[2]
	           ? (branch && (memwb_pc != pc))
	           : 1'b0;

	/* disassemble the instruction */
	assign opcode = ifid_instruction[31:21];
	assign rm     = ifid_instruction[20:16];
	assign shamt  = ifid_instruction[15:10];
	assign rn     = ifid_instruction[9:5];
	assign rd     = ifid_instruction[4:0];

	/* registers to be read from the registers */
	assign ra = control[`REG1LOC] ? `XZR : rn;
	assign rb = control[`REG2LOC] ? rd : rm;

	/* forwarding operand */
	assign forwardop = exmem_control[`REGSRC1:`REGSRC0] == `REGSRC_MOV ? exmem_movres : exmem_alures;
	assign forwardeda = forwarda[`FORWARDUSE]
	                  ? (forwarda[`FORWARDSRC] ? forwardop : writereg)
	                  : idex_readreg1;
	assign forwardedb = forwardb[`FORWARDUSE]
	                  ? (forwardb[`FORWARDSRC] ? forwardop : writereg)
	                  : idex_readreg2;

	/* operand of the MOV Unit */
	assign movoperand = forwarda[`FORWARDUSE]
	                  ? (forwarda[`FORWARDSRC] ? forwardop : writereg)
	                  : idex_readreg2;

	/* operands of the ALU */
	assign alua = idex_control[`ALU1SRC]
	            ? idex_pc
	            : forwardeda;
	assign alub = idex_control[`ALU2SRC]
	            ? idex_extended
	            : forwardedb;

	/* data to be written back on the registers */
	assign writereg = memwb_control[`REGSRC1:`REGSRC0] == `REGSRC_PC ? memwb_pc
	                : memwb_control[`REGSRC1:`REGSRC0] == `REGSRC_MOV ? memwb_movres
	                : memwb_control[`REGSRC1:`REGSRC0] == `REGSRC_MEM ? memwb_readmem
	                : memwb_alures;

	/* count stages */
	always @(posedge clk)
		if (stage < {`COUNTERSIZE{1'b1}})
			stage++;

	/* IF-ID register */
	ifid ifid(clk, stall, nop, pc, instruction, ifid_nop, ifid_pc, ifid_instruction);

	/* ID-EX register */
	idex idex(clk, nop,
	          ifid_nop,
	          (stall ? {`IDEX_CONTROLSIZE{1'b0}} : control[`IDEX_CONTROLSIZE-1:0]),
	          opcode,
	          aluop,
	          movop,
	          ifid_pc,
	          readreg1,
	          readreg2,
	          extended,
	          shamt,
	          ra,
	          rb,
	          rd,
	          idex_nop,
	          idex_control,
	          idex_opcode,
	          idex_aluop,
	          idex_movop,
	          idex_pc,
	          idex_readreg1,
	          idex_readreg2,
	          idex_extended,
	          idex_shamt,
	          idex_ra,
	          idex_rb,
	          idex_rd);

	/* EX-MEM register */
	exmem exmem(clk, nop,
	            idex_nop,
	            idex_control[`EXMEM_CONTROLSIZE-1:0],
	            idex_opcode,
	            idex_pc,
	            alures,
	            movres,
	            forwardedb,
	            flagstoset,
	            idex_rd,
	            exmem_nop,
	            exmem_control,
	            exmem_opcode,
	            exmem_pc,
	            exmem_alures,
	            exmem_movres,
	            exmem_readreg2,
	            exmem_flagstoset,
	            exmem_rd);

	/* MEM-WB register */
	memwb memwb(clk, nop,
	            exmem_nop,
	            exmem_control[`MEMWB_CONTROLSIZE-1:0],
	            exmem_opcode,
	            exmem_pc,
	            exmem_alures,
	            exmem_movres,
	            readmem,
	            exmem_readreg2,
	            readflags,
	            exmem_rd,
	            memwb_control,
	            memwb_opcode,
	            memwb_pc,
	            memwb_alures,
	            memwb_movres,
	            memwb_readmem,
	            memwb_readreg2,
	            memwb_readflags,
	            memwb_rd);

	/* Hazard Detection Unit: decides whether to stall pipeline */
	hazard hazard(stage, idex_control[`MEMREAD], opcode,
	              rn, rm, rd, idex_rd,
	              stall);

	/* Forwarding Unit: decides whether to forward when a data hazard occurs */
	forward forward(stage,
	                exmem_control[`REGWRITE],
	                memwb_control[`REGWRITE],
	                exmem_opcode,
	                memwb_opcode,
	                idex_ra,
	                idex_rb,
	                exmem_rd,
	                memwb_rd,
	                forwarda,
	                forwardb);

	/* Program Counter: get address of next instruction */
	programcounter programcounter(clk, rst, stall,
	                              (stage[2] ? branch : 1'b0),
	                              memwb_alures,
	                              pc);

	/* Program Memory: get instruction from the address in the program counter */
	memprog memprog(pc, instruction);

	/* Control Unit: set the control signals and the alu and mov operations */
	controlunit controlunit(opcode, control, aluop, movop);

	/* Sign Extension: extend the immediate or address in the instruction */
	signextension signextension(ifid_instruction, extended);

	/* Register File: read and write registers from the register file */
	registerfile registerfile(clk, rst,
	                          ra,
	                          rb,
	                          (memwb_control[`REGSRC1:`REGSRC0] == `REGSRC_PC ? `XLR : memwb_rd),
	                          writereg,
	                          memwb_control[`REGWRITE],
	                          readreg1,
	                          readreg2);

	/* MOV Unit: how many bits to shift the second alu operand */
	mov mov(movoperand, idex_extended, idex_movop, movres);

	/* Arithmetic-Logic Unit: perform operation specified in aluop */
	alu alu(alua, alub, idex_shamt, idex_aluop, alures, flagstoset);

	/* read and write data from/into the memory */
	memdata memdata(clk, rst, exmem_alures, exmem_readreg2,
	                exmem_control[`MEMREAD], exmem_control[`MEMWRITE],
	                readmem);

	/* control the flags register */
	flagsregister flagsreg(clk, rst, exmem_control[`SETFLAGS], exmem_flagstoset, readflags);

	/* Branch Control: control whether to branch */
	branchcontrol branchcontrol(memwb_opcode, memwb_readreg2, memwb_rd, memwb_readflags, branch);
endmodule
