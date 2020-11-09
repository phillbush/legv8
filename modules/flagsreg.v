`include "bus.vh"

module flagsregister(clk, reset, setflags, flagstoset, flags);
	input wire clk;
	input wire reset;
	input wire setflags;
	input wire [`FLAGSIZE-1:0] flagstoset;
	output reg [`FLAGSIZE-1:0] flags;

	initial
		flags <= 4'b0;

	always @(posedge clk)
		if (reset)
			flags <= 4'b0;
		else if (setflags)
			flags <= flagstoset;
endmodule
