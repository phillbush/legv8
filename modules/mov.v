`include "bus.vh"
`include "opcode.vh"
`include "movop.vh"

module mov(readreg, extended, movop, movres);
	input wire [`WORDSIZE-1:0] readreg;
	input wire [`WORDSIZE-1:0] extended;
	input wire [`MOVOPSIZE-1:0] movop;
	output wire [`WORDSIZE-1:0] movres;
	wire [`WORDSIZE-1:0] array[0:3];
	wire movkeep;

	assign movkeep = movop[2];

	assign array[`MOVSHIFT48] = ~({{48{1'b0}}, {16{1'b1}}} << 'd48);
	assign array[`MOVSHIFT32] = ~({{48{1'b0}}, {16{1'b1}}} << 'd32);
	assign array[`MOVSHIFT16] = ~({{48{1'b0}}, {16{1'b1}}} << 'd16);
	assign array[`MOVSHIFT00] = ~({{48{1'b0}}, {16{1'b1}}});

	assign movres = (movkeep ? readreg & array[movop[1:0]] : {`WORDSIZE{1'b0}}) | extended;
endmodule
