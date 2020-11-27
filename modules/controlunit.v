`include "bus.vh"
`include "control.vh"
`include "opcode.vh"
`include "aluop.vh"
`include "movop.vh"

module controlunit(opcode, control, aluop, movop);
	input wire [`OPCODESIZE-1:0] opcode;
	output wire [`CONTROLSIZE-1:0] control;
	output wire [`ALUOPSIZE-1:0] aluop;
	output wire [`MOVOPSIZE-1:0] movop;

	wire op_mov;
	wire op_b;
	wire op_cb;
	wire op_bflag;
	wire op_shift;
	wire op_ldur;
	wire op_stur;
	wire op_i;
	wire op_branch;
	wire op_restoreg;
	wire [2:0] ri_upper;
	wire [2:0] ri_lower;
	wire setflags;

	assign op_b        = (opcode & `B_MASK) == `B_BITSET;
	assign op_cb       = (opcode & `CB_MASK) == `CB_BITSET;
	assign op_bflag    = (opcode & `BFLAG_MASK) == `BFLAG_BITSET;
	assign op_shift    = (opcode & `SHIFT_MASK) == `SHIFT_BITSET;
	assign op_mov      = (opcode & `MOV_MASK) == `MOV_BITSET;
	assign op_ldur     = (opcode & `LDUR_MASK) == `LDUR_BITSET;
	assign op_stur     = (opcode & `STUR_MASK) == `STUR_BITSET;
	assign op_i        = (opcode & `I_MASK) == `I_BITSET;
	assign op_r        = (opcode & `R_MASK) == `R_BITSET;
	assign op_ri       = op_r | op_i;
	assign op_branch   = op_cb | op_bflag | op_b;
	assign op_restoreg = op_mov | op_shift | op_ri;

	/* upper 3 bits and lower 3:1 bits for R- and I- format opcodes */
	assign ri_upper = opcode[`OPCODESIZE-1:`OPCODESIZE-3];
	assign ri_lower = opcode[3:1];

	/* whether instruction is a set-flags instruction */
	assign setflags = ((ri_upper == 'b111 && ri_lower == 'b000)     /* AND(I)S */
	                || (ri_upper == 'b101 && ri_lower == 'b100)     /* ADD(I)S */
	                || (ri_upper == 'b111 && ri_lower == 'b100));   /* SUB(I)S */

	assign control[`REG1LOC]  = op_cb | op_shift | op_bflag;
	assign control[`REG2LOC]  = op_cb | op_ldur | op_stur | op_mov;
	assign control[`USEMOV]   = op_mov;
	assign control[`ALU1SRC]  = op_branch;
	assign control[`ALU2SRC]  = op_ldur | op_stur | op_i | op_branch;
	assign control[`SETFLAGS] = op_ri && setflags;
	assign control[`MEMREAD]  = op_ldur;
	assign control[`MEMWRITE] = op_stur;
	assign control[`REGWRITE] = control[`PCTOREG] | control[`MEMTOREG] | op_restoreg;
	assign control[`PCTOREG]  = op_b && opcode[`OPCODESIZE-1];
	assign control[`MEMTOREG] = op_ldur;

	/* control the operation to be performed by MOV */
	movcontrol movcontrol(opcode[`OPCODESIZE-3], opcode[1:0], movop);

	/* control the operation to be performed by ALU */
	alucontrol alucontrol(ri_upper, ri_lower, opcode[0], op_shift, op_ri, aluop);
endmodule

module movcontrol(movkeep, movlsb, movop);
	input wire movkeep;
	input wire [1:0] movlsb;
	output wire [`MOVOPSIZE-1:0] movop;

	assign movop = {movkeep, movlsb};
endmodule

module alucontrol(ri_upper, ri_lower, shiftdir, op_shift, op_ri, aluop);
	input wire [2:0] ri_upper;
	input wire [2:0] ri_lower;
	input wire shiftdir;
	input wire op_shift;
	input wire op_ri;
	output wire [`ALUOPSIZE-1:0] aluop;

	/* wires to set the alu operation */
	wire [`ALUOPSIZE-1:0] aluop_r;
	wire alu_inva;          /* whether to invert ALU's operand A */
	wire alu_invb;          /* whether to invert ALU's operand B */
	wire alu_shift;         /* whether to shift ALU's result */
	wire alu_shdir;         /* direction to shift ALU's result */
	wire [1:0] alu_op;      /* operation ALU should perform */
	wire [1:0] alu_op_ri;   /* operation ALU should perform */

	assign alu_inva = 1'b0;
	assign alu_invb = op_ri && (ri_upper[2:1] == 2'b11 && ri_lower == 4'b100);
	assign alu_shift = op_shift;
	assign alu_shdir = op_shift && shiftdir;
	assign alu_op_ri = (ri_upper == 'b100 && ri_lower == 'b100) ? `ALUOP_ADD /* ADD(I) */
	                 : (ri_upper == 'b110 && ri_lower == 'b100) ? `ALUOP_ADD /* SUB(I) */
	                 : (ri_upper == 'b100 && ri_lower == 'b000) ? `ALUOP_AND /* AND(I) */
	                 : (ri_upper == 'b101 && ri_lower == 'b000) ? `ALUOP_ORR /* ORR(I) */
	                 : (ri_upper == 'b110 && ri_lower == 'b000) ? `ALUOP_EOR /* EOR(I) */
	                 : (ri_upper == 'b111 && ri_lower == 'b000) ? `ALUOP_AND /* AND(I)S */
	                 : (ri_upper == 'b101 && ri_lower == 'b100) ? `ALUOP_ADD /* ADD(I)S */
	                 : (ri_upper == 'b111 && ri_lower == 'b100) ? `ALUOP_ADD /* SUB(I)S */
	                 : `ALUOP_ADD;
	assign alu_op = op_shift ? `ALUOP_ORR
	              : op_ri ? alu_op_ri
	              : `ALUOP_ADD;
	assign aluop = {alu_inva, alu_invb, alu_shift, alu_shdir, alu_op};
endmodule
