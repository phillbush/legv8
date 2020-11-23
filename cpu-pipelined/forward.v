`include "bus.vh"
`include "forward.vh"
`include "opcode.vh"
`include "registers.vh"

module forward(exmem_regwrite, memwb_regwrite, exmem_opcode, memwb_opcode, idex_ra, idex_rb, exmem_rd, memwb_rd, forwarda, forwardb);
	input wire exmem_regwrite;
	input wire memwb_regwrite;
	input wire [`OPCODESIZE-1:0] exmem_opcode;
	input wire [`OPCODESIZE-1:0] memwb_opcode;
	input wire [`REGADDRSIZE-1:0] idex_ra;
	input wire [`REGADDRSIZE-1:0] idex_rb;
	input wire [`REGADDRSIZE-1:0] exmem_rd;
	input wire [`REGADDRSIZE-1:0] memwb_rd;
	output wire [`FORWARDSIZE-1:0] forwarda;
	output wire [`FORWARDSIZE-1:0] forwardb;

	wire forwarda_exmem;
	wire forwardb_exmem;
	wire forwarda_memwb;
	wire forwardb_memwb;
	wire exmem_branch;
	wire memwb_branch;

        assign exmem_branch = (exmem_opcode & `BRANCH_MASK) == `BRANCH_BITSET;
        assign memwb_branch = (memwb_opcode & `BRANCH_MASK) == `BRANCH_BITSET;

	assign forwarda_exmem = !exmem_branch && exmem_regwrite && (exmem_rd != `XZR) && (exmem_rd == idex_ra);
	assign forwardb_exmem = !exmem_branch && exmem_regwrite && (exmem_rd != `XZR) && (exmem_rd == idex_rb);
	assign forwarda_memwb = !memwb_branch && memwb_regwrite && (memwb_rd != `XZR) && (memwb_rd == idex_ra);
	assign forwardb_memwb = !memwb_branch && memwb_regwrite && (memwb_rd != `XZR) && (memwb_rd == idex_rb);

	assign forwarda[`FORWARDUSE] = forwarda_exmem || forwarda_memwb;
	assign forwardb[`FORWARDUSE] = forwardb_exmem || forwardb_memwb;
	assign forwarda[`FORWARDSRC] = forwarda_exmem;
	assign forwardb[`FORWARDSRC] = forwardb_exmem;
endmodule
