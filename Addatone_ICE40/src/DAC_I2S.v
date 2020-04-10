module DAC_I2S
#(parameter CLOCK_TICKS = 1500)		// Number of clock ticks from one full LR sample to the next
	(
		input wire i_clock,
		input wire i_reset,
		input wire [31:0] i_data,
		output reg o_LR_clock,
		output reg o_bit_clock,
		output reg o_data
	);

	reg [4:0] clock_counter;
	reg [5:0] bit_counter;
	reg [0:63] send_data;				// Merge left and right data into one vector
	reg waitForSync;

	always @(posedge i_clock) begin
		if (i_reset) begin
			clock_counter <= 1'b0;
		end
		else begin
			clock_counter <= clock_counter + 1'b1;
			if (clock_counter == (CLOCK_TICKS / 64)) begin
				clock_counter <= 1'b0;
			end
		end
	end

	always @(posedge i_clock) begin
		if (i_reset) begin
			bit_counter <= 1'b0;
			o_LR_clock <= 1'b0;			// High = left channel, Low = right
			o_bit_clock <= 1'b0;
		end
		else begin
			if (clock_counter == (CLOCK_TICKS / 64) / 2)
				o_bit_clock <= ~o_bit_clock;

			if(clock_counter == (CLOCK_TICKS / 64)) begin
				o_bit_clock <= ~o_bit_clock;
				bit_counter <= bit_counter + 1;

				// flip LR clock - note that for I2S this changes one bit clock before the next sample is sent
				if (bit_counter == 30 || bit_counter == 62) begin
					o_LR_clock <= ~o_LR_clock;
				end
				// new pair of samples
				if (bit_counter == 63) begin
					send_data <= {i_data, i_data};
				end
			end

			o_data <= send_data[bit_counter];
		end

	end

endmodule

/*
bit clock: 72MHz/ (64 samples * 48kHz) = 23.43

*/