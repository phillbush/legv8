`include "bus.vh"

module programcounter(clk, reset, branch, extended, pc);
	input wire clk;
	input wire reset;
	input wire branch;
	input wire [`WORDSIZE-1:0] extended;
	output reg [`WORDSIZE-1:0] pc;

	initial
		pc <= {`WORDSIZE{1'b0}};

	always @(posedge clk or posedge reset)
		if (reset)
			pc = {`WORDSIZE{1'b0}};
		else
			pc = (branch ? pc + extended : pc + 'd4);
endmodule
