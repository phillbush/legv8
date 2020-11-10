`include "bus.vh"
`include "aluop.vh"

module alu(a, b, shamt, aluop, res, flags);

	input wire signed [`WORDSIZE-1:0] a;     /* operand A */
	input wire signed [`WORDSIZE-1:0] b;     /* operand B */
	input wire [`SHAMTSIZE-1:0] shamt;       /* shift amount */
	input wire [`ALUOPSIZE-1:0] aluop;       /* operation to be performed */
	output wire signed [`WORDSIZE-1:0] res;  /* alu result */
	output wire [`FLAGSIZE-1:0] flags;       /* result flags */

	wire [`WORDSIZE:0] array[0:3];           /* array of possible results */
	wire [`WORDSIZE:0] useda;                /* value of operand B to be used */
	wire [`WORDSIZE:0] usedb;                /* value of operand A to be used */
	wire shift;                              /* whether to shift */
	wire shdir;                              /* shift direction (1 to right, 0 to left) */

	/* value of operands to be used */
	assign useda = aluop[5] ? {1'b0, ~a} : {1'b0, a};
	assign usedb = aluop[4] ? {1'b0, ~b} : {1'b0, b};

	/* set shift parameters */
	assign shift = aluop[3];
	assign shdir = aluop[2];

	/* operations */
	assign array[`ALUOP_AND] = useda & usedb;
	assign array[`ALUOP_ORR] = useda | usedb;
	assign array[`ALUOP_ADD] = useda + usedb;
	assign array[`ALUOP_EOR] = useda ^ usedb;

	/* result */
	assign res = shdir
	           ? array[aluop[1:0]][`WORDSIZE-1:0] << (shift ? shamt : 0)
	           : array[aluop[1:0]][`WORDSIZE-1:0] >> (shift ? shamt : 0);

	/* flags (NZVC) */
	assign flags[3] = res[`WORDSIZE-1];
	assign flags[2] = ~(|res[`WORDSIZE-1:0]);
	assign flags[1] = (usedb[`WORDSIZE-1] == useda[`WORDSIZE-1]) && (res[`WORDSIZE-1] != useda[`WORDSIZE-1]);
	assign flags[0] = array[aluop[1:0]][`WORDSIZE];
endmodule
