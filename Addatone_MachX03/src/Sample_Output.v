module Sample_Output
	#(parameter SAMPLE_OFFSET = 32'h20500, parameter SEND_CHANNEL_A = 8'b00110001, parameter SEND_CHANNEL_B = 8'b00110010)
	(
		input wire i_Clock,
		input wire i_Reset,
		input wire i_Start,
		input wire [31:0] i_Sample_L,
		input wire [31:0] i_Sample_R,
		output wire o_SPI_CS,
		output wire o_SPI_Clock,
		output wire o_SPI_Data
	);
	
	reg [31:0] r_Sample_L;
	reg [31:0] r_Sample_R;
	reg [23:0] Output_Data;
	wire DAC_Ready;
	
	reg DAC_Send;
	DAC_SPI_Out dac(.i_Clock(i_Clock), .i_Reset(i_Reset), .i_Data(Output_Data), .i_Send(DAC_Send), .o_SPI_CS(o_SPI_CS), .o_SPI_Clock(o_SPI_Clock), .o_SPI_Data(o_SPI_Data), .o_Ready(DAC_Ready));

	reg [3:0] SM_Sample_Output;
	localparam sm_waiting = 3'd0;
	localparam sm_send_L = 3'd1;
	localparam sm_delay_L = 3'd2;
	localparam sm_send_R = 3'd3;
	localparam sm_delay_R = 3'd4;	

	
	
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
					// add the required offset to the sample
					if (i_Start && DAC_Ready) begin
						r_Sample_L <= i_Sample_L + SAMPLE_OFFSET;
						r_Sample_R <= i_Sample_R + SAMPLE_OFFSET;
						SM_Sample_Output <= sm_send_L;
					end
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
					SM_Sample_Output <= sm_send_R;
				end
				
			
			// Wait until left sample has been sent then transmit right sample
			sm_send_R:
				if (DAC_Ready) begin
					Output_Data <= {SEND_CHANNEL_B, r_Sample_R[17:2]};
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
	
		