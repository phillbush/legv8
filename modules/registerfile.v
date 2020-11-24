`include "bus.vh"
`include "registers.vh"

module registerfile(clk, reset, rn, rm, rd, in, wren, outn, outm);
	input wire clk;
	input wire reset;
	input wire [`REGADDRSIZE-1:0] rn;        /* register n */
	input wire [`REGADDRSIZE-1:0] rm;        /* register m */
	input wire [`REGADDRSIZE-1:0] rd;        /* register d */
	input wire [`WORDSIZE-1:0] in;           /* input data */
	input wire wren;                        /* write enable */
	output wire [`WORDSIZE-1:0] outn;        /* content of register n */
	output wire [`WORDSIZE-1:0] outm;        /* content of register m */

	reg [`WORDSIZE-1:0] registers[0:(2**`REGADDRSIZE)-1];
	integer i;

	/* read at any time */
	assign outn = registers[rn];
	assign outm = registers[rm];

	/* write on the positive edge of the clock */
	always @(posedge clk or posedge reset)
		if (reset)
			for (i = 0; i < 2**`REGADDRSIZE; i++)
				registers[i] <= {`WORDSIZE{1'b0}};
		else if (wren && rd != `XZR)
			registers[rd] <= in;
endmodule
