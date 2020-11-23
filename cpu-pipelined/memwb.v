`include "bus.vh"

module memwb(clk, nop, nopin,
             controlin,  opcodein,  pcin,  branchpcin,  aluresin,  movresin,  readmemin,  zeroin,  readflagsin,  rdin,
             controlout, opcodeout, pcout, branchpcout, aluresout, movresout, readmemout, zeroout, readflagsout, rdout);
	input wire clk;
	input wire nop;
	input wire nopin;
	input wire [`MEMWB_CONTROLSIZE-1:0] controlin;
	input wire [`OPCODESIZE-1:0] opcodein;
	input wire [`WORDSIZE-1:0] pcin;
	input wire [`WORDSIZE-1:0] branchpcin;
	input wire [`WORDSIZE-1:0] readmemin;
	input wire [`WORDSIZE-1:0] aluresin;
	input wire [`WORDSIZE-1:0] movresin;
	input wire zeroin;
	input wire [`FLAGSIZE-1:0] readflagsin;
	input wire [`REGADDRSIZE-1:0] rdin;
	output reg nopout;
	output reg [`MEMWB_CONTROLSIZE-1:0] controlout;
	output reg [`OPCODESIZE-1:0] opcodeout;
	output reg [`WORDSIZE-1:0] pcout;
	output reg [`WORDSIZE-1:0] branchpcout;
	output reg [`WORDSIZE-1:0] readmemout;
	output reg [`WORDSIZE-1:0] aluresout;
	output reg [`WORDSIZE-1:0] movresout;
	output reg zeroout;
	output reg [`FLAGSIZE-1:0] readflagsout;
	output reg [`REGADDRSIZE-1:0] rdout;

	always @(posedge clk)
	begin
		if (nop || nopin)
			controlout <= 'b0;
		else
			controlout <= controlin;
		opcodeout    <= opcodein;
		pcout        <= pcin;
		branchpcout  <= branchpcin;
		readmemout   <= readmemin;
		aluresout    <= aluresin;
		movresout    <= movresin;
		aluresout    <= aluresin;
		zeroout      <= zeroin;
		readflagsout <= readflagsin;
		rdout        <= rdin;
	end
endmodule
