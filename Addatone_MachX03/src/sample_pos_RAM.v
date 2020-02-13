// Inferred Single Port RAM
module Sample_Pos_RAM (din, addr, write_en, clk, dout);
	parameter addr_width = 8;
	parameter data_width = 16;
	input [addr_width-1:0] addr;
	input [data_width-1:0] din;
	output [data_width-1:0] dout;
	input write_en, clk;

	// Define RAM as an indexed memory array.
	reg [data_width - 1:0] mem [(1 << addr_width) - 1:0];

	integer i;

	initial
	begin
		for (i = 0; i < 256; i = i + 1)
		begin
			mem[i] = 1'b0;
		end
	end

	always @(posedge clk)	// Control with a clock edge.
	begin
		if (write_en)			// And control with a write enable.
			mem[(addr)] <= din;
	end

	assign dout = mem[addr];
endmodule