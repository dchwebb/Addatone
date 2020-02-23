/*
 Module allows fractional calculations of 16 bit values. Set DIVISOR_BITS to control the resolution of fractions.
 Increasing the divisor bits increases the resolution of the fractions at the cost of a clock cycle per bit; 7 gives 2^7 = 128 fractions
 Eg 7 gives 128 fractions: multiple must be a number between 0 and 127; the result is calculated as result = (multiple / 128) * in
*/
module Fraction
	#(parameter DIVISOR_BITS = 7)
	(
	input wire clock, reset, start, clear_accumulator,
	input wire [DIVISOR_BITS - 1:0] multiple,
	input wire signed [15:0] in,
	output reg [31:0] accumulator,
	output reg done
	);

	// working registers
	reg signed [31:0] in_reg;
	reg [DIVISOR_BITS - 1:0] mult_reg;
	reg signed [31:0] working_total;
	reg [4:0] counter;

	always @(posedge clock) begin
		if (reset) begin
			counter <= 1'b0;
			done <= 1'b1;
			accumulator <= 1'b0;
		end
		else if (clear_accumulator) begin
			accumulator <= 1'b0;
		end
		else begin
			if (start && counter == 1'b0) begin
				counter <= 1'b1;
				done <= 1'b0;
				working_total <= multiple[0] ? in : 0;

				// store input values to registers to preserve values
				in_reg <= in;
				mult_reg <= (multiple >> 1);
			end
			else if (counter > 0) begin

				if (mult_reg == 0) begin
					// Multiplication complete - divide by bit count and add to accumulator, retaining negative bits
					accumulator <= accumulator + {{DIVISOR_BITS{working_total[31]}}, working_total[31:DIVISOR_BITS]};
					//accumulator <= accumulator + working_total >> (DIVISOR_BITS);
					done <= 1'b1;
					counter <= 0;
				end
				else begin
					// if bit is set in multiplier bit shift the input and add to the working_total
					counter <= counter + 1'b1;
					mult_reg <= mult_reg >> 1;
					if (mult_reg[0] == 1'b1) begin
						working_total <= working_total + (in_reg << counter);
					end
				end
			end
		end

	end

endmodule