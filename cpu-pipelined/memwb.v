`include "bus.vh"

module memwb(clk, nop, nopin,
             controlin,  opcodein,  pcin,  resin,  readmemin,  readreg2in,  readflagsin,  rdin,
             controlout, opcodeout, pcout, resout, readmemout, readreg2out, readflagsout, rdout);
	input wire clk;
	input wire nop;
	input wire nopin;
	input wire [`MEMWB_CONTROLSIZE-1:0] controlin;
	input wire [`OPCODESIZE-1:0] opcodein;
	input wire [`WORDSIZE-1:0] pcin;
	input wire [`WORDSIZE-1:0] readmemin;
	input wire [`WORDSIZE-1:0] resin;
	input wire [`WORDSIZE-1:0] readreg2in;
	input wire [`FLAGSIZE-1:0] readflagsin;
	input wire [`REGADDRSIZE-1:0] rdin;
	output reg nopout;
	output reg [`MEMWB_CONTROLSIZE-1:0] controlout;
	output reg [`OPCODESIZE-1:0] opcodeout;
	output reg [`WORDSIZE-1:0] pcout;
	output reg [`WORDSIZE-1:0] readmemout;
	output reg [`WORDSIZE-1:0] resout;
	output reg [`WORDSIZE-1:0] readreg2out;
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
		readmemout   <= readmemin;
		resout       <= resin;
		readreg2out  <= readreg2in;
		readflagsout <= readflagsin;
		rdout        <= rdin;
	end
endmodule
