`include "bus.vh"
`include "opcode.vh"

module signextension(instruction, long);
	input wire [`INSTSIZE-1:0] instruction;
	output wire [`WORDSIZE-1:0] long;

	wire [`OPCODESIZE-1:0] opcode;
	wire [`SHORTSIZE-1:0] short;

	wire [`WORDSIZE-1:0] alu_imm;
	wire [`WORDSIZE-1:0] mov_imm;
	wire [`WORDSIZE-1:0] dt_addr;
	wire [`WORDSIZE-1:0] cb_addr;
	wire [`WORDSIZE-1:0] b_addr;

	assign opcode = {instruction[`INSTSIZE-1:`INSTSIZE-`OPCODESIZE]};
	assign short  = {instruction[`SHORTSIZE-1:0]};

	assign alu_imm = {52'b0, short[21:10]};

	assign mov_imm = {48'b0, short[20:5]};

	assign b_addr = {{36{short[25]}}, short[25:0], 2'b0};

	assign cb_addr = {{43{short[23]}}, short[23:5], 2'b0};

	assign dt_addr = {{55{short[20]}}, short[20:12]};

	assign long = ((opcode & `B_MASK) == `B_BITSET) ? b_addr
	            : ((opcode & `CB_MASK) == `CB_BITSET
	            || (opcode & `BFLAG_MASK) == `BFLAG_BITSET) ? cb_addr
	            : ((opcode & `MOV_MASK) == `MOV_BITSET) ? mov_imm
	            : ((opcode & `LDUR_MASK) == `LDUR_BITSET
	            || (opcode & `STUR_MASK) == `STUR_BITSET) ? dt_addr
	            : alu_imm;
 endmodule
