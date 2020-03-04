module scale_mult
	#(parameter DIV_BIT = 8)
	(
		input i_clock,
		input wire i_start,
		input wire i_restart,
		input wire [DIV_BIT - 1:0] i_scale,
		input wire [DIV_BIT - 1:0] i_initial,
		output reg [DIV_BIT - 1:0] o_mult
	);
	
	always @(posedge i_clock) begin
		if (i_restart) begin
			//o_mult <= (2 ** DIV_BIT) - 1;
			o_mult <= i_initial;
		end
		else
		if (i_start) begin
			if (o_mult >= i_scale)
				o_mult <= o_mult - i_scale;
			else
				o_mult <= 1'b0;
		end
	end
		
endmodule