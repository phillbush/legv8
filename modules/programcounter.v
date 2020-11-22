`include "bus.vh"

module programcounter(clk, rst, stall, branch, branchpc, pc);
	input wire clk;
	input wire rst;
	input wire stall;
	input wire branch;
	input wire [`WORDSIZE-1:0] branchpc;
	output reg [`WORDSIZE-1:0] pc;

	initial
		pc <= {`WORDSIZE{1'b0}};

	always @(posedge clk or posedge rst)
		if (rst)
			pc <= {`WORDSIZE{1'b0}};
		else if (!stall)
			pc <= (branch ? branchpc : pc + 'd4);
endmodule
