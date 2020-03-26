/*
 Module adding of scaled samples. Scaling allows fractional calculations of 16 bit values. Set DIVISOR_BITS to control the resolution of fractions.
 Increasing the divisor bits increases the resolution of the fractions at the cost of a clock cycle per bit; 7 gives 2^7 = 128 fractions
 Eg 7 gives 128 fractions: multiple must be a number between 0 and 127; the result is calculated as result = (i_Multiple / 128) * i_Sample
*/
module Adder
	#(parameter DIVISOR_BITS = 9)
	(
		input wire i_Clock, i_Reset, i_Start, i_Clear_Accumulator,
		input wire signed [15:0] i_Multiple,
		input wire signed [15:0] i_Sample,
		output reg signed [31:0] o_Accumulator,
		output reg o_Done
	);

	reg signed [31:0] Working_Total;

	localparam sm_wait = 2'b00;
	localparam sm_mult = 2'b01;
	reg [1:0] SM_Adder = sm_wait;

	initial begin
		o_Done <= 1'b1;
		o_Accumulator <= 1'b0;
	end

	always @(posedge i_Clock or posedge i_Clear_Accumulator) begin //
		if (i_Reset || i_Clear_Accumulator) begin		// 
			SM_Adder = sm_wait;
			o_Done <= 1'b1;
			o_Accumulator <= 1'b0;
		end
		else begin
			case (SM_Adder)
				sm_wait:
					begin
						
						if (i_Start) begin
							o_Done <= 1'b0;
							Working_Total <= i_Multiple * i_Sample;
							SM_Adder = sm_mult;
						end
					end

				sm_mult:
					begin
						// Divide by bit count and add to o_Accumulator, retaining negative bits
						//o_Accumulator <= o_Accumulator + {{DIVISOR_BITS + (31 - WTSIZE){Working_Total[WTSIZE]}}, Working_Total[WTSIZE:DIVISOR_BITS]};
						o_Accumulator <= o_Accumulator + {{DIVISOR_BITS{Working_Total[31]}}, Working_Total[31:DIVISOR_BITS]};
						o_Done <= 1'b1;
						SM_Adder = sm_wait;
					end

			endcase
		end
	end

endmodule