`include "bus.vh"
`include "flags.vh"
`include "opcode.vh"

module branchcontrol(opcode, rd, flags, zero, branch);
	input wire [`OPCODESIZE-1:0] opcode;
	input wire [`REGADDRSIZE-1:0] rd;
	input wire [`FLAGSIZE-1:0] flags;
	input wire zero;
	output reg branch;

	wire flagbranch[0:15];
	wire unconditional;
	wire conditional;
	wire flagbased;
	wire n;
	wire z;
	wire v;
	wire c;

	/* disassemble the flags */
	assign n = flags[3];
	assign z = flags[2];
	assign v = flags[1];
	assign c = flags[0];

	/* branch based on flags */
	assign flagbranch['h0] = z;                /* B.EQ */
	assign flagbranch['h1] = ~z;               /* B.NE */
	assign flagbranch['h2] = c;                /* B.HS */
	assign flagbranch['h3] = ~c;               /* B.LO */
	assign flagbranch['h4] = n;                /* B.MI */
	assign flagbranch['h5] = ~n;               /* B.PL */
	assign flagbranch['h6] = v;                /* B.VS */
	assign flagbranch['h7] = ~v;               /* B.VC */
	assign flagbranch['h8] = ~z & c;           /* B.HI */
	assign flagbranch['h9] = ~(~z & c);        /* B.LS */
	assign flagbranch['ha] = (n == v);         /* B.GE */
	assign flagbranch['hb] = (n != v);         /* B.LT */
	assign flagbranch['hc] = ~z & (n == v);    /* B.GT */
	assign flagbranch['hd] = ~(~z & (n == v)); /* B.LE */
	assign flagbranch['he] = 1'b0;
	assign flagbranch['hf] = 1'b0;

	/* whether to unconditionally branch */
	assign unconditional = (opcode & `B_MASK) == `B_BITSET;

	/* whether conditionally branch based on the state of zero */
	assign conditional =  ((opcode & `CB_MASK) == `CB_BITSET)
	                   && ((~opcode[3] && zero) || (opcode[3] && ~zero));

	/* whether to conditionally branch based on flags */
	assign flagbased = ((opcode & `BFLAG_MASK) == `BFLAG_BITSET)
	                 && flagbranch[rd[3:0]];

	/* set whether to branch */
	always @(*) begin
		if (unconditional | conditional | flagbased)
			branch <= 1'b1;
		else
			branch <= 1'b0;
	end
endmodule
