`include "bus.vh"
`include "memory.vh"

module memdata(clk, reset, addr, in, rden, wren, out);
	input wire clk;
	input wire reset;
	input wire [`WORDSIZE-1:0] addr;        /* address */
	input wire [`WORDSIZE-1:0] in;          /* input data */
	input wire rden;                        /* read enable */
	input wire wren;                        /* write enable */
	output wire [`WORDSIZE-1:0] out;        /* output data */

	reg [`BYTESIZE-1:0] data[0:`MEMDATASIZE-1];
	integer i;

	initial
		$readmemh(`DATAFILE, data);

	assign out = rden
	           ? {data[addr], data[addr + 1], data[addr + 2], data[addr + 3],
	              data[addr + 4], data[addr + 5], data[addr + 6], data[addr + 7]}
	           : {`WORDSIZE{1'b0}};

	always @(posedge clk or posedge reset)
		if (reset)
			$readmemh(`DATAFILE, data);
		else if (wren)
		begin
			data[addr] = in[63:56];
			data[addr + 1] = in[55:48];
			data[addr + 2] = in[47:40];
			data[addr + 3] = in[39:32];
			data[addr + 4] = in[31:24];
			data[addr + 5] = in[23:16];
			data[addr + 6] = in[15:8];
			data[addr + 7] = in[7:0];
		end
endmodule
