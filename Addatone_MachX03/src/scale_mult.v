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
		input wire [7:0] i_Comb_Interval,
		input wire i_Comb_Active,
		output reg [DIV_BIT - 1:0] o_Mult,
		output reg o_Mult_Ready = 1'b1
	);

	reg [DIV_BIT - 1:0] r_Mult_Out;
	reg [7:0] Comb_Counter;

	reg [1:0] SM_Scale_Mult;
	localparam sm_ready = 2'd0;
	localparam sm_comb = 2'd1;
	localparam sm_scaled = 2'd2;
	localparam sm_mute = 2'd3;

	initial begin
		SM_Scale_Mult <= sm_ready;
	end

	always @(posedge i_Clock) begin
		if (i_Restart) begin
			r_Mult_Out <= i_Initial;
			Comb_Counter <= 1'b0;
			o_Mult_Ready <= 1'b1;
			SM_Scale_Mult <= sm_ready;
		end
		else begin
			case (SM_Scale_Mult)

				sm_ready:
					if (i_Start) begin
						o_Mult_Ready <= 1'b0;
						if (r_Mult_Out >= i_Scale)
							r_Mult_Out <= r_Mult_Out - i_Scale;
						else
							r_Mult_Out <= 1'b0;
						
						SM_Scale_Mult <= i_Comb_Active ? sm_comb : sm_scaled;
					end
					
				sm_comb:
					begin
						SM_Scale_Mult <= sm_scaled;
						
						Comb_Counter <= Comb_Counter + 1'b1;
						if (Comb_Counter == i_Comb_Interval) begin
							SM_Scale_Mult <= sm_mute;
						end
					end
					
				sm_mute:
					begin
						Comb_Counter <= 1'b0;
						o_Mult_Ready <= 1'b1;
						o_Mult <= 1'b0;
						SM_Scale_Mult <= sm_ready;
					end
					
				sm_scaled:
					begin
						o_Mult <= r_Mult_Out;
						o_Mult_Ready <= 1'b1;
						SM_Scale_Mult <= sm_ready;
					end
			endcase
		end
	end

endmodule