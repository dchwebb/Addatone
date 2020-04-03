module Sample_Output
	#(parameter SAMPLE_OFFSET = 32'h1FFFF, parameter SEND_CHANNEL_A = 8'b00110001, parameter SEND_CHANNEL_B = 8'b00110010)
	(
		input wire i_Clock,
		input wire i_Reset,
		input wire i_Start,
		input wire signed [31:0] i_Sample_L,
		input wire signed [31:0] i_Sample_R,
		output wire o_SPI_CS,
		output wire o_SPI_Clock,
		output wire o_SPI_Data,
		output reg o_Debug
	);
	
	reg signed [31:0] r_Sample_L;
	reg signed [31:0] r_Sample_R;
	reg [23:0] Output_Data;
	wire DAC_Ready;
	
	reg DAC_Send;
	DAC_SPI_Out dac(.i_Clock(i_Clock), .i_Reset(i_Reset), .i_Data(Output_Data), .i_Send(DAC_Send), .o_SPI_CS(o_SPI_CS), .o_SPI_Clock(o_SPI_Clock), .o_SPI_Data(o_SPI_Data), .o_Ready(DAC_Ready));

	localparam sm_waiting = 4'd0;
	localparam sm_send_L = 4'd1;
	localparam sm_delay_L = 4'd2;
	localparam sm_send_R = 4'd3;
	localparam sm_delay_R = 4'd4;	
	localparam sm_test_L = 4'd5;
	localparam sm_test_R = 4'd6;
	localparam sm_prepare_L = 4'd7;
	localparam sm_prepare_R = 4'd8;	
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
					// add the required offset to the sample
					if (i_Start && DAC_Ready) begin
						r_Sample_L <= i_Sample_L;
						r_Sample_R <= i_Sample_R;

						SM_Sample_Output <= sm_test_L;
					end
				end
			
			sm_test_L:
				// Ensure that sample does not overflow when converted from 32 to 16 bit
				begin
					if (r_Sample_L > 32'sd131_071) begin
						r_Sample_L <= 32'sd131_071;
					end
					if (r_Sample_L < -32'sd131_071) begin
						r_Sample_L <= -32'sd131_071;
					end					
				
					
					SM_Sample_Output <= sm_prepare_L;
				end

			sm_prepare_L:
				begin
					r_Sample_L <= r_Sample_L + SAMPLE_OFFSET;
					SM_Sample_Output <= sm_send_L;
				end
				
			// scale the sample and add DAC SPI channel information
			sm_send_L:
				begin
					Output_Data <= {SEND_CHANNEL_A, r_Sample_L[17:2]};
					DAC_Send <= 1'b1;
					SM_Sample_Output <= sm_delay_L;
				end
				
			// delay until DAC updates DAC_Ready status
			sm_delay_L:
				if (!DAC_Ready) begin
					DAC_Send <= 1'b0;
					if (r_Sample_R > 32'sd131_071) begin
						r_Sample_R <= 32'sd131_071;
					end

					SM_Sample_Output <= sm_test_R;
				end

			sm_test_R:
				begin
					r_Sample_R <= r_Sample_R + SAMPLE_OFFSET;
					SM_Sample_Output <= sm_prepare_R;
				end

			sm_prepare_R:
				begin
					//if (r_Sample_R[31] == 1'b1) begin
						//r_Sample_R <= 32'b0;
						//o_Debug <= 1'b1;
					//end					

					SM_Sample_Output <= sm_send_R;
				end
			
			// Wait until left sample has been sent then transmit right sample
			sm_send_R:
				if (DAC_Ready) begin
					Output_Data <= {SEND_CHANNEL_B, r_Sample_R[31] == 1'b1 ? 16'b0 : r_Sample_R[17:2]};		// Kludge to prevent timing errors - only right sample needs scaling here
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
	
		