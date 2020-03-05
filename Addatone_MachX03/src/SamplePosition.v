module SamplePosition
	(
		input wire i_reset,
		input wire i_clock,
		input wire [15:0] i_frequency,
		input wire [7:0] i_harmonic,
		output reg o_sample_ready,					// Tells top module that sample position has been loaded
		input wire i_next_sample,					// Trigger from top module to say current value has been read and ready for next sample
		output wire [15:0] o_sample_value
	);

	reg sp_write;
	wire [15:0] sp_readdata;
	reg [15:0] sample_position;
	reg [10:0] lut_pos;

	// Initialise Sample Position RAM (IP)
	SamplePos_RAM sample_pos_ram(.Clock(i_clock), .ClockEn(1'b1), .Reset(i_reset), .WE(sp_write), .Address(i_harmonic), .Data(sample_position), .Q(sp_readdata));

	// Initialise Sine LUT
	SineLUT sin_lut (.Address(lut_pos), .OutClock(i_clock), .OutClockEn(1'b1), .Reset(i_reset), .Q(o_sample_value));

	reg [16:0] accumulated_frequency;
	reg [2:0] state_machine;
	localparam [2:0] sm_init = 3'd0;
	localparam [2:0] sm_sample_pos = 3'd1;
	localparam [2:0] sm_sine_lut = 3'd2;
	localparam [2:0] sm_waiting = 3'd3;
	
	always @(posedge i_clock) begin
		if (i_reset) begin
			sp_write <= 1'b0;
			o_sample_ready <= 1'b0;
			sample_position <= 1'b0;
			state_machine <= sm_init;
			lut_pos <= 1'b0;
		end
		else begin
			case (state_machine)
				sm_init:
					begin
						accumulated_frequency <= i_frequency;
						o_sample_ready <= 1'b0;
						sp_write <= 1'b0;
						state_machine <= sm_sample_pos;
					end
					
				sm_sample_pos:
					begin
						// increment next sample position by frequency: number of items in sine LUT is 2048 (32*2048=65536) which means that we can divide by 32 to get correct position
						sample_position <= sp_readdata + accumulated_frequency;
						sp_write <= 1'b1;
						state_machine <= sm_sine_lut;
					end

				sm_sine_lut:
					begin
						// sample position is ready pass to sine LUT to get sample value
						o_sample_ready <= 1'b1;
						sp_write <= 1'b0;
						lut_pos <= sample_position[15:5];
						state_machine <= sm_waiting;
					end
					
				sm_waiting:
					// Once sample has been read by top restart
					begin
						if (i_next_sample) begin
							accumulated_frequency <= accumulated_frequency + i_frequency;
							o_sample_ready <= 1'b0;
							state_machine <= (i_harmonic == 1'b0) ? sm_init : sm_sample_pos;
						end
					end
			endcase
		end
		
	end

endmodule