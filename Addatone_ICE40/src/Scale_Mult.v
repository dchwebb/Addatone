/*
	Reduces the scaling multiple as each harmonic is progressively attenuated by i_Scale from initial value of i_Initial
*/
module Scale_Mult
	#(parameter DIV_BIT = 11)
	(
		input i_Clock,
		input wire i_Start,
		input wire i_Restart,
		input wire [DIV_BIT - 1:0] i_Scale,
		input wire [DIV_BIT - 1:0] i_Initial,
		output reg [DIV_BIT - 1:0] o_Mult = 1'b0,
		output reg o_Mult_Ready = 1'b1
	);

	reg [DIV_BIT - 1:0] r_Mult_Out;

	localparam sm_ready = 1'b0;
	localparam sm_done = 1'b1;
	reg SM_Scale_Mult = sm_ready;

	initial begin
		o_Mult = 1'b0;
		SM_Scale_Mult <= sm_ready;
	end

	always @(posedge i_Clock) begin
		if (i_Restart) begin
			o_Mult <= i_Initial;
			o_Mult_Ready <= 1'b1;
			SM_Scale_Mult <= sm_ready;
		end
		else begin
			case (SM_Scale_Mult)

				sm_ready:
					if (i_Start) begin
						o_Mult_Ready <= 1'b0;
						if (o_Mult >= i_Scale)
							o_Mult <= o_Mult - i_Scale;
						else
							o_Mult <= 1'b0;

						SM_Scale_Mult <= sm_done;
					end

				sm_done:
					begin
						o_Mult_Ready <= 1'b1;
						SM_Scale_Mult <= sm_ready;
					end
			endcase
		end
	end

endmodule