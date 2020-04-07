module Ring_Mod
	#(parameter SAMPLE_OFFSET = 20'sh7FFF)
	(
		input wire i_Clock,
		input wire signed [19:0] i_Sample1,
		input wire signed [19:0] i_Sample2,
		input wire i_Start,
		output reg [15:0] o_Result,
		output reg o_Ready
	);
	
	reg signed [29:0] Calc;
	reg signed [19:0] Calc_Scaled;
	//reg signed [15:0] Calc_Scaled2;
	reg signed [19:0] r_Sample1;
	reg signed [19:0] r_Sample2;
	reg signed [15:0] Sample1_Scaled;
	reg signed [15:0] Sample2_Scaled;
	
	localparam sm_waiting = 3'd0;
	localparam sm_scale_input = 3'd1;
	localparam sm_multiply = 3'd2;
	localparam sm_scale_output1 = 3'd3;
	localparam sm_scale_output2 = 3'd4;
	localparam sm_scale_output3 = 3'd5;
	localparam sm_done = 3'd6;
	reg [2:0] SM_Ring_Mod = sm_waiting;


	always @(posedge i_Clock) begin
		case (SM_Ring_Mod)
		sm_waiting:
			begin
				o_Ready <= 1'b1;
				if (i_Start) begin
					o_Ready <= 1'b0;
					r_Sample1 <= i_Sample1 > SAMPLE_OFFSET ? SAMPLE_OFFSET : i_Sample1;
					r_Sample2 <= i_Sample2 > SAMPLE_OFFSET ? SAMPLE_OFFSET : i_Sample2;
					SM_Ring_Mod <= sm_scale_input;
				end
			end

		sm_scale_input:
			begin
				Sample1_Scaled <= r_Sample1 < -SAMPLE_OFFSET ? -SAMPLE_OFFSET[15:0] : r_Sample1[15:0];
				Sample2_Scaled <= r_Sample2 < -SAMPLE_OFFSET ? -SAMPLE_OFFSET[15:0] : r_Sample2[15:0];
				SM_Ring_Mod <= sm_multiply;
			end

		sm_multiply:
			begin
				Calc <= Sample1_Scaled * Sample2_Scaled;
				SM_Ring_Mod <= sm_scale_output1;
			end
			
		sm_scale_output1:
			begin
				Calc_Scaled <= Calc >>> 11;
				SM_Ring_Mod <= sm_scale_output2;
			end
			
		sm_scale_output2:
			begin
				Calc_Scaled <= Calc_Scaled < -SAMPLE_OFFSET ? -SAMPLE_OFFSET : Calc_Scaled;
				SM_Ring_Mod <= sm_scale_output3;
			end
			
		sm_scale_output3:
			begin
				o_Result <= Calc_Scaled > SAMPLE_OFFSET ? SAMPLE_OFFSET : Calc_Scaled;
				SM_Ring_Mod <= sm_done;
			end

		sm_done:
			begin
				o_Ready <= 1'b1;
				SM_Ring_Mod <= sm_waiting;
			end
		endcase
	end
	
endmodule