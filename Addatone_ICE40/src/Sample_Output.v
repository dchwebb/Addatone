module Sample_Output
	#(parameter SAMPLE_OFFSET = 20'sh7FFF, parameter SAMPLE_LIMIT = 20'sd30000, parameter SEND_CHANNEL_A = 8'b00110001, parameter SEND_CHANNEL_B = 8'b00110010)
	(
		input wire i_Clock,
		input wire i_Reset,
		input wire i_Start,
		input wire signed [31:0] i_Sample_L,
		input wire signed [31:0] i_Sample_R,
		input wire i_Mix,
		input wire i_Ring_Mod,
		output wire o_I2S_LR_Clock,
		output wire o_I2S_Bit_Clock,
		output wire o_I2S_Data
	);

	reg r_Ring_Mod;
	reg signed [19:0] r_Sample_L = 1'b0;
	reg signed [19:0] r_Sample_R = 1'b0;
	reg signed [31:0] Sample_Mix = 1'b0;
	wire signed [15:0] Ring_Mod;
	reg signed [31:0] Output_Odd = 1'b0;
	reg signed [31:0] Output_Even = 1'b0;

	reg Ring_Mod_Start;
	wire RM_Ready;
	Ring_Mod rm(.i_Clock(i_Clock), .i_Sample1(r_Sample_L), .i_Sample2(r_Sample_R), .i_Start(Ring_Mod_Start), .o_Result(Ring_Mod), .o_Ready(RM_Ready));

	DAC_I2S dac2(.i_Clock(i_Clock), .i_Reset(i_Reset), .i_Data_Odd(Output_Odd), .i_Data_Even(Output_Even), .o_LR_Clock(o_I2S_LR_Clock), .o_Bit_Clock(o_I2S_Bit_Clock), .o_Data(o_I2S_Data));

	localparam sm_waiting = 4'd0;
	localparam sm_mix1 = 4'd1;
	localparam sm_mix2 = 4'd2;
	localparam sm_limit_low = 4'd3;
	localparam sm_limit_high = 4'd4;
	localparam sm_offset = 4'd5;
	localparam sm_send_L = 4'd6;
	localparam sm_delay_L = 4'd7;
	localparam sm_send_R = 4'd8;
	localparam sm_delay_R = 4'd9;
	reg [3:0] SM_Sample_Output = sm_waiting;

	always @(posedge i_Clock) begin
		if (i_Reset) begin
			r_Sample_L <= 1'b0;
			r_Sample_R <= 1'b0;
			SM_Sample_Output <= sm_waiting;
		end
		else begin

			case (SM_Sample_Output)
			sm_waiting:
				begin

					// Divide sample by 4
					if (i_Start) begin
						r_Sample_L <= i_Sample_L[21:0] >>> 2;
						r_Sample_R <= i_Sample_R[21:0] >>> 2;
						r_Ring_Mod <= i_Ring_Mod;
						Ring_Mod_Start <= i_Ring_Mod;

						SM_Sample_Output <= i_Mix ? sm_mix1 : sm_limit_low;
					end
				end

			sm_mix1:
				begin
					Sample_Mix <= r_Sample_L + r_Sample_R;

					SM_Sample_Output <= sm_mix2;
				end

			sm_mix2:
				begin
					r_Sample_L <= Sample_Mix[19:0];

					SM_Sample_Output <= sm_limit_low;
				end

			sm_limit_low:
				// Limit low value of sample
				begin
					Ring_Mod_Start <= 1'b0;
					r_Sample_L <= r_Sample_L < -SAMPLE_LIMIT ? -SAMPLE_LIMIT : r_Sample_L;
					r_Sample_R <= r_Sample_R < -SAMPLE_LIMIT ? -SAMPLE_LIMIT : r_Sample_R;

					SM_Sample_Output <= sm_limit_high;
				end


			sm_limit_high:
				// Ensure that sample does not overflow when converted from 32 to 16 bit		// sd65535
				begin
					if (r_Sample_L > SAMPLE_LIMIT) begin
						r_Sample_L <= SAMPLE_LIMIT;

					end
					if (r_Sample_R > SAMPLE_LIMIT) begin
						r_Sample_R <= SAMPLE_LIMIT;
					end

					SM_Sample_Output <= sm_send_L;
				end


			// Add DAC SPI channel information and trigger send
			sm_send_L:
				begin
					Output_Odd <= r_Sample_L[15:0] <<< 16;
					SM_Sample_Output <= sm_delay_L;
				end

			// Delay until Ring Mod has finished
			sm_delay_L:
				if (RM_Ready) begin

					if (r_Ring_Mod)
						r_Sample_R = Ring_Mod;

					SM_Sample_Output <= sm_send_R;
				end

			sm_send_R:
				begin
					Output_Even <= r_Sample_R[15:0] <<< 16;
					SM_Sample_Output <= sm_waiting;
				end

			endcase
		end
	end

endmodule

