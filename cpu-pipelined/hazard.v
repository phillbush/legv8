`include "bus.vh"
`include "opcode.vh"
`include "registers.vh"

module hazard(stage, idex_memread, opcode, rn, rm, rt, idex_rd, stall);
	input wire [`COUNTERSIZE-1:0] stage;
	input wire idex_memread;
	input wire [`OPCODESIZE-1:0] opcode;
	input wire [`OPCODESIZE-1:0] idex_opcode;
	input wire [`OPCODESIZE-1:0] exmem_opcode;
	input wire [`REGADDRSIZE-1:0] rn;
	input wire [`REGADDRSIZE-1:0] rm;
	input wire [`REGADDRSIZE-1:0] rt;
	input wire [`REGADDRSIZE-1:0] idex_rd;
	output reg stall;

	always @(*) begin
		if ((stage > 3'b001)
	           && idex_memread
	           && ((rn == idex_rd)
	           || (((opcode & `R_MASK) == `R_BITSET) && (rm == idex_rd))
	           || (((opcode & `STUR_MASK) == `STUR_BITSET) && (rt == idex_rd))))
			stall <= 1'b1;
		else
			stall <= 1'b0;
	end
endmodule
