`include "bus.vh"

module exmem(clk, nop,
             nopin,  controlin,  opcodein,  pcin,  branchpcin,  aluresin,  movresin,  readreg2in,  flagstosetin,  rdin,
             nopout, controlout, opcodeout, pcout, branchpcout, aluresout, movresout, readreg2out, flagstosetout, rdout);
	input wire clk;
	input wire nop;
	input wire nopin;
	input wire [`EXMEM_CONTROLSIZE-1:0] controlin;
	input wire [`OPCODESIZE-1:0] opcodein;
	input wire [`WORDSIZE-1:0] pcin;
	input wire [`WORDSIZE-1:0] branchpcin;
	input wire [`WORDSIZE-1:0] aluresin;
	input wire [`WORDSIZE-1:0] movresin;
	input wire [`WORDSIZE-1:0] readreg2in;
	input wire [`FLAGSIZE-1:0] flagstosetin;
	input wire [`REGADDRSIZE-1:0] rdin;
	output reg nopout;
	output reg [`EXMEM_CONTROLSIZE-1:0] controlout;
	output reg [`OPCODESIZE-1:0] opcodeout;
	output reg [`WORDSIZE-1:0] pcout;
	output reg [`WORDSIZE-1:0] branchpcout;
	output reg [`WORDSIZE-1:0] aluresout;
	output reg [`WORDSIZE-1:0] movresout;
	output reg [`WORDSIZE-1:0] readreg2out;
	output reg [`FLAGSIZE-1:0] flagstosetout;
	output reg [`REGADDRSIZE-1:0] rdout;

	always @(posedge clk)
	begin
		if (nop || nopin)
			controlout <= 'b0;
		else
			controlout <= controlin;
		nopout        <= nop | nopin;
		opcodeout     <= opcodein;
		pcout         <= pcin;
		branchpcout   <= branchpcin;
		aluresout     <= aluresin;
		movresout     <= movresin;
		readreg2out   <= readreg2in;
		flagstosetout <= flagstosetin;
		rdout         <= rdin;
	end
endmodule
