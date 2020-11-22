`include "bus.vh"
`include "forward.vh"
`include "registers.vh"

module forward(exmem_regwrite, memwb_regwrite, idex_ra, idex_rb, exmem_rd, memwb_rd, forwarda, forwardb);
	input wire exmem_regwrite;
	input wire memwb_regwrite;
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

	assign forwarda_exmem = exmem_regwrite && (exmem_rd != `XZR) && (exmem_rd == idex_ra);
	assign forwardb_exmem = exmem_regwrite && (exmem_rd != `XZR) && (exmem_rd == idex_rb);
	assign forwarda_memwb = memwb_regwrite && (memwb_rd != `XZR) && (memwb_rd == idex_ra);
	assign forwardb_memwb = memwb_regwrite && (memwb_rd != `XZR) && (memwb_rd == idex_rb);

	assign forwarda[`FORWARDUSE] = forwarda_exmem || forwarda_memwb;
	assign forwardb[`FORWARDUSE] = forwardb_exmem || forwardb_memwb;
	assign forwarda[`FORWARDSRC] = forwarda_exmem;
	assign forwardb[`FORWARDSRC] = forwardb_exmem;
endmodule
