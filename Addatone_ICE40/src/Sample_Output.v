module Sample_Output
	#(parameter SAMPLE_OFFSET = 20'sh7FFF, parameter SEND_CHANNEL_A = 8'b00110001, parameter SEND_CHANNEL_B = 8'b00110010)
	(
		input wire i_Clock,
		input wire i_Reset,
		input wire i_Start,
		input wire signed [31:0] i_Sample_L,
		input wire signed [31:0] i_Sample_R,
		input wire i_Mix,
		input wire i_Ring_Mod,		
		output wire o_SPI_CS,
		output wire o_SPI_Clock,
		output wire o_SPI_Data,
		output reg o_Debug
	);
	
	reg r_Ring_Mod;
	reg signed [19:0] r_Sample_L;
	reg signed [19:0] r_Sample_R;
	reg signed [31:0] Sample_Mix;
	wire signed [15:0] Ring_Mod;	
	reg [23:0] Output_Data;
	wire DAC_Ready;

	reg Ring_Mod_Start;
	wire RM_Ready;
	Ring_Mod rm(.i_Clock(i_Clock), .i_Sample1(r_Sample_L), .i_Sample2(r_Sample_R), .i_Start(Ring_Mod_Start), .o_Result(Ring_Mod), .o_Ready(RM_Ready));
	
	reg DAC_Send;
	DAC_SPI_Out dac(.i_Clock(i_Clock), .i_Reset(i_Reset), .i_Data(Output_Data), .i_Send(DAC_Send), .o_SPI_CS(o_SPI_CS), .o_SPI_Clock(o_SPI_Clock), .o_SPI_Data(o_SPI_Data), .o_Ready(DAC_Ready));

	localparam sm_waiting = 4'd0;
	localparam sm_send_L = 4'd1;
	localparam sm_delay_L = 4'd2;
	localparam sm_send_R = 4'd3;
	localparam sm_delay_R = 4'd4;	
	localparam sm_limit_low = 4'd5;
	localparam sm_prepare = 4'd6;
	localparam sm_mix1 = 4'd7;
	localparam sm_mix2 = 4'd8;
	localparam sm_offset = 4'd9;	
	localparam sm_limit_high = 4'd10;
	reg [4:0] SM_Sample_Output = sm_waiting;
	
	always @(posedge i_Clock) begin
		if (i_Reset) begin
			DAC_Send <= 1'b0;
			r_Sample_L <= 1'b0;
			r_Sample_R <= 1'b0;
			SM_Sample_Output <= sm_waiting;
		end
		else begin
			
			case (SM_Sample_Output)
			sm_waiting:
				begin
					DAC_Send <= 1'b0;
					o_Debug <= 1'b0;
					// Divide sample by 4
					if (i_Start && DAC_Ready) begin
						r_Sample_L <= i_Sample_L >>> 2;
						r_Sample_R <= i_Sample_R >>> 2;
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
					r_Sample_L <= Sample_Mix;
	
					SM_Sample_Output <= sm_limit_low;
				end



			sm_limit_low:
				begin
					Ring_Mod_Start <= 1'b0;
					// if sample is still negative after applying offset set to zero - otherwise divide by 4
					r_Sample_L <= r_Sample_L < -SAMPLE_OFFSET ? -SAMPLE_OFFSET : r_Sample_L;
					r_Sample_R <= r_Sample_R < -SAMPLE_OFFSET ? -SAMPLE_OFFSET : r_Sample_R;
					//if (r_Sample_L < -SAMPLE_OFFSET) begin
						//r_Sample_L <= -SAMPLE_OFFSET;
					//end
					//if (r_Sample_R < -SAMPLE_OFFSET) begin
						//r_Sample_R <= -SAMPLE_OFFSET;
					//end

					SM_Sample_Output <= sm_limit_high;
				end


			sm_limit_high:
				// Ensure that sample does not overflow when converted from 32 to 16 bit		// sd65535
				begin
					if (r_Sample_L > SAMPLE_OFFSET) begin
						r_Sample_L <= SAMPLE_OFFSET;

					end
					if (r_Sample_R > SAMPLE_OFFSET) begin
						r_Sample_R <= SAMPLE_OFFSET;
					end				
				
					SM_Sample_Output <= sm_offset;
				end

			sm_offset:
				begin
					r_Sample_L <= r_Sample_L + SAMPLE_OFFSET;
					r_Sample_R <= r_Sample_R + SAMPLE_OFFSET;					
					SM_Sample_Output <= sm_send_L;			
				end
				
			// Add DAC SPI channel information and trigger send
			sm_send_L:
				begin
					Output_Data <= {SEND_CHANNEL_A, r_Sample_L[15:0]};
					DAC_Send <= 1'b1;
					SM_Sample_Output <= sm_delay_L;
				end
				
			// Delay until DAC updates DAC_Ready status
			sm_delay_L:
				if (!DAC_Ready && RM_Ready) begin
					DAC_Send <= 1'b0;
					if (r_Ring_Mod)
						r_Sample_R = Ring_Mod + SAMPLE_OFFSET;

					SM_Sample_Output <= sm_send_R;
				end

			// Wait until left sample has been sent then transmit right sample
			sm_send_R:
				if (DAC_Ready) begin
					Output_Data <= {SEND_CHANNEL_B, r_Sample_R[15:0]};
					DAC_Send <= 1'b1;
					SM_Sample_Output <= sm_delay_R;
				end

			sm_delay_R:
				if (!DAC_Ready) begin
					DAC_Send <= 1'b0;
					SM_Sample_Output <= sm_waiting;
				end
			
			endcase
		end
	end
	
endmodule
	
		