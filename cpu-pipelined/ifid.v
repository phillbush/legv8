`include "bus.vh"

module ifid(clk, stall, nopin, pcin, instin, nopout, pcout, instout);
	input wire clk;
	input wire stall;
	input wire nopin;
	input wire [`WORDSIZE-1:0] pcin;
	input wire [`INSTSIZE-1:0] instin;
	output reg nopout;
	output reg [`WORDSIZE-1:0] pcout;
	output reg [`INSTSIZE-1:0] instout;

	always @(posedge clk)
	begin
		if (!stall) begin
			pcout   <= pcin;
			instout <= instin;
		end
		nopout <= nopin;
	end
endmodule
