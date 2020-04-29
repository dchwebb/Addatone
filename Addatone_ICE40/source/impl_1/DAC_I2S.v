module DAC_I2S
#(parameter CLOCK_TICKS = 1000)		// Number of clock ticks from one full LR sample to the next
	(
		input wire i_Clock,
		input wire i_Reset,
		input wire signed [31:0] i_Data_Odd,
		input wire signed [31:0] i_Data_Even,
		output reg o_LR_Clock = 1'b0,
		output reg o_Bit_Clock = 1'b0,
		output reg o_Data
	);

	reg [4:0] Clock_Counter = 1'b0;
	reg [5:0] Bit_Counter = 1'b0;
	reg [0:63] Send_Data = 1'b0;				// Merge left and right data into one vector

	// Clock_Counter used to control bit clock - at 48MHz the Clock_Counter ticks 15 times for each cycle of the Bit clock
	always @(posedge i_Clock) begin
		if (i_Reset) begin
			Clock_Counter <= 1'b0;
		end
		else begin
			Clock_Counter <= Clock_Counter + 1'b1;
			if (Clock_Counter == (CLOCK_TICKS / 64)) begin
				Clock_Counter <= 1'b0;
			end
		end
	end

	always @(posedge i_Clock) begin
		if (i_Reset) begin
			Bit_Counter <= 1'b0;
			o_LR_Clock <= 1'b0;			// High = left channel, Low = right
			o_Bit_Clock <= 1'b0;
		end
		else begin
			if (Clock_Counter == (CLOCK_TICKS / 64) / 2)
				o_Bit_Clock <= ~o_Bit_Clock;

			if(Clock_Counter == (CLOCK_TICKS / 64)) begin
				o_Bit_Clock <= ~o_Bit_Clock;
				Bit_Counter <= Bit_Counter + 1;

				// flip LR clock - note that for I2S this changes one bit clock before the next sample is sent
				if (Bit_Counter == 30 || Bit_Counter == 62) begin
					o_LR_Clock <= ~o_LR_Clock;
				end
				// new pair of samples - clock them in at either the L or R transition to ensure using latest value
				if (Bit_Counter == 63 || Bit_Counter == 31) begin
					Send_Data <= {i_Data_Odd, i_Data_Even};
				end
			end

			o_Data <= Send_Data[Bit_Counter];
		end

	end

endmodule
