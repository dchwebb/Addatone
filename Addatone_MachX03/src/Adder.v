/*
 Module adding of scaled samples. Scaling allows fractional calculations of 16 bit values. Set DIVISOR_BITS to control the resolution of fractions.
 Increasing the divisor bits increases the resolution of the fractions at the cost of a clock cycle per bit; 7 gives 2^7 = 128 fractions
 Eg 7 gives 128 fractions: multiple must be a number between 0 and 127; the result is calculated as result = (i_Multiple / 128) * i_Sample
*/
module Adder
	#(parameter DIVISOR_BITS = 7)
	(
		input wire i_Clock, i_Reset, i_Start, i_Clear_Accumulator,
		input wire [DIVISOR_BITS - 1:0] i_Multiple,
		input wire signed [15:0] i_Sample,
		output reg signed [31:0] o_Accumulator,
		output reg o_Done
	);

	// working registers
	reg signed [31:0] r_Sample_In;
	reg [DIVISOR_BITS - 1:0] r_Multiple;
	reg signed [31:0] Working_Total;
	reg [4:0] Counter;

	initial begin
		Counter <= 1'b0;
		o_Done <= 1'b1;
		o_Accumulator <= 1'b0;
	end
	
	always @(posedge i_Clock or posedge i_Clear_Accumulator) begin //
		if (i_Clear_Accumulator) begin		// i_Reset || 
			Counter <= 1'b0;
			o_Done <= 1'b1;
			o_Accumulator <= 1'b0;
		end
		else begin
			if (i_Start && Counter == 1'b0) begin
				Counter <= 1'b1;
				o_Done <= 1'b0;
				Working_Total <= i_Multiple[0] ? i_Sample : 0;

				// store input values to registers to preserve values
				r_Multiple <= (i_Multiple >> 1);
				r_Sample_In <= i_Sample;
			end
			else if (Counter > 0) begin
				if (r_Multiple == 0) begin
					// Multiplication complete - divide by bit count and add to o_Accumulator, retaining negative bits
					//o_Accumulator <= o_Accumulator + {{DIVISOR_BITS{Working_Total[31]}}, Working_Total[31:DIVISOR_BITS]};
					o_Accumulator <= o_Accumulator + (Working_Total >>> DIVISOR_BITS);
					o_Done <= 1'b1;
					Counter <= 0;
				end
				else begin
					// if bit is set in multiplier bit shift the input and add to the Working_Total
					Counter <= Counter + 1'b1;
					r_Multiple <= r_Multiple >> 1;
					if (r_Multiple[0] == 1'b1) begin
						Working_Total <= Working_Total + (r_Sample_In << Counter);
					end
				end
			end
		end

	end

endmodule