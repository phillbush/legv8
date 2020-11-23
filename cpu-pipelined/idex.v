`include "bus.vh"

module idex(clk, nop,
            nopin, controlin,  opcodein,  aluopin,  movopin,  pcin,  readreg1in,  readreg2in,  extendedin,  shamtin,  rain,  rbin,  rdin,
            nopout, controlout, opcodeout, aluopout, movopout, pcout, readreg1out, readreg2out, extendedout, shamtout, raout, rbout, rdout);
	input wire clk;
	input wire nop;
	input wire nopin;
	input wire [`IDEX_CONTROLSIZE-1:0] controlin;
	input wire [`OPCODESIZE-1:0] opcodein;
	input wire [`ALUOPSIZE-1:0] aluopin;
	input wire [`MOVOPSIZE-1:0] movopin;
	input wire [`WORDSIZE-1:0] pcin;
	input wire [`WORDSIZE-1:0] readreg1in;
	input wire [`WORDSIZE-1:0] readreg2in;
	input wire [`WORDSIZE-1:0] extendedin;
	input wire [`SHAMTSIZE-1:0] shamtin;
	input wire [`REGADDRSIZE-1:0] rain;
	input wire [`REGADDRSIZE-1:0] rbin;
	input wire [`REGADDRSIZE-1:0] rdin;
	output reg nopout;
	output reg [`IDEX_CONTROLSIZE-1:0] controlout;
	output reg [`OPCODESIZE-1:0] opcodeout;
	output reg [`ALUOPSIZE-1:0] aluopout;
	output reg [`MOVOPSIZE-1:0] movopout;
	output reg [`WORDSIZE-1:0] pcout;
	output reg [`WORDSIZE-1:0] readreg1out;
	output reg [`WORDSIZE-1:0] readreg2out;
	output reg [`WORDSIZE-1:0] extendedout;
	output reg [`SHAMTSIZE-1:0] shamtout;
	output reg [`REGADDRSIZE-1:0] raout;
	output reg [`REGADDRSIZE-1:0] rbout;
	output reg [`REGADDRSIZE-1:0] rdout;

	always @(posedge clk)
	begin
		if (nop || nopin)
			controlout <= 'b0;
		else
			controlout <= controlin;
		nopout      <= nop | nopin;
		opcodeout   <= opcodein;
		aluopout    <= aluopin;
		movopout    <= movopin;
		pcout       <= pcin;
		readreg1out <= readreg1in;
		readreg2out <= readreg2in;
		extendedout <= extendedin;
		shamtout    <= shamtin;
		raout       <= rain;
		rbout       <= rbin;
		rdout       <= rdin;
	end
endmodule
