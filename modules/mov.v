`include "bus.vh"
`include "opcode.vh"

module mov(opcode, readreg, extended, movres);
	input wire [`OPCODESIZE-1:0] opcode;
	input wire [`WORDSIZE-1:0] readreg;
	input wire [`WORDSIZE-1:0] extended;
	output wire [`WORDSIZE-1:0] movres;
	wire [`WORDSIZE-1:0] shifted;
	wire [`SHAMTSIZE-1:0] movshift;
	wire movk;

	assign movk = opcode[`OPCODESIZE-3];

	assign movshift = opcode[1]
	                ? (opcode[0] ? 'd48 : 'd32)
	                : (opcode[0] ? 'd16 : 'd0);

	assign shifted = movk ? readreg & ~({{48{1'b0}}, {16{1'b1}}} << movshift) : {`WORDSIZE{1'b0}};

	assign movres = shifted | extended;
endmodule
