`include "bus.vh"
`include "memory.vh"

module memprog(pc, instruction);
	input wire [`WORDSIZE-1:0] pc;
	output wire [`INSTSIZE-1:0] instruction;

	reg [`BYTESIZE-1:0] data[0:`MEMPROGSIZE-1];

	initial
		$readmemh(`TEXTFILE, data);

	assign instruction = {data[pc], data[pc+1], data[pc+2], data[pc+3]};
endmodule
