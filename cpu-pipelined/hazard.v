`include "bus.vh"
`include "opcode.vh"
`include "registers.vh"

module hazard(stage, idex_memread, opcode, memwb_opcode, rn, rm, rt, idex_rd, stall);
	input wire [`COUNTERSIZE-1:0] stage;
	input wire idex_memread;
	input wire [`OPCODESIZE-1:0] opcode;
	input wire [`OPCODESIZE-1:0] memwb_opcode;
	input wire [`REGADDRSIZE-1:0] rn;
	input wire [`REGADDRSIZE-1:0] rm;
	input wire [`REGADDRSIZE-1:0] rt;
	input wire [`REGADDRSIZE-1:0] idex_rd;
	output wire stall;

	wire ldur_stall;
	wire branch_stall;
	wire branch_done;

	assign branch_done = (stage > 3'b011) && ((memwb_opcode & `BRANCH_MASK) == `BRANCH_BITSET);

	assign branch_stall = ((opcode & `BRANCH_MASK) == `BRANCH_BITSET) && !branch_done;

	assign ldur_stall =  idex_memread
		          && ((rn == idex_rd)
			  || (((opcode & `R_MASK) == `R_BITSET) && (rm == idex_rd))
			  || (((opcode & `STUR_MASK) == `STUR_BITSET) && (rt == idex_rd)));

	assign stall = ((stage > 3'b001) && ldur_stall) || ((stage > 3'b000) && branch_stall);
endmodule
