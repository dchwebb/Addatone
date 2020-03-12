/*
	Reduces the scaling multiple as each harmonic is progressively attenuated by i_Scale from initial value of i_Initial
*/
module Scale_Mult
	#(parameter DIV_BIT = 8)
	(
		input i_Clock,
		input wire i_Start,
		input wire i_Restart,
		input wire [DIV_BIT - 1:0] i_Scale,
		input wire [DIV_BIT - 1:0] i_Initial,
		output reg [DIV_BIT - 1:0] o_Mult
	);
	
	always @(posedge i_Clock) begin
		if (i_Restart) begin
			o_Mult <= i_Initial;
		end
		else
		if (i_Start) begin
			if (o_Mult >= i_Scale)
				o_Mult <= o_Mult - i_Scale;
			else
				o_Mult <= 1'b0;
		end
	end
		
endmodule