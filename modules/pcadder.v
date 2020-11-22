`include "bus.vh"

module pcadder(pc, extended, branchpc);
	input wire [`WORDSIZE-1:0] pc;
	input wire [`WORDSIZE-1:0] extended;
	output wire [`WORDSIZE-1:0] branchpc;

	assign branchpc = pc + extended;
endmodule
