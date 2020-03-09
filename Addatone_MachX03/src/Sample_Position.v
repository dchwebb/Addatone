module Sample_Position
	(
		input wire i_Reset,
		input wire i_Clock,
		input wire [15:0] i_Frequency,
		input wire [7:0] i_Harmonic,
		output reg o_Sample_Ready,					// Tells top module that sample position has been loaded
		input wire i_Next_Sample,					// Trigger from top module to say current value has been read and ready for next sample
		output wire [15:0] o_Sample_Value,
		output reg o_Freq_Too_High
	);

	reg sp_write;
	wire [15:0] sp_readdata;
	reg [15:0] sample_position;
	reg [10:0] lut_pos;

	// Initialise Sample Position RAM (IP)
	SamplePos_RAM sample_pos_ram(.Clock(i_Clock), .ClockEn(1'b1), .Reset(i_Reset), .WE(sp_write), .Address(i_Harmonic), .Data(sample_position), .Q(sp_readdata));

	// Initialise Sine LUT
	SineLUT sin_lut (.Address(lut_pos), .OutClock(i_Clock), .OutClockEn(1'b1), .Reset(i_Reset), .Q(o_Sample_Value));

	reg [15:0] accumulated_frequency;
	reg [2:0] state_machine;
	localparam [2:0] sm_init = 3'd0;
	localparam [2:0] sm_sample_pos = 3'd1;
	localparam [2:0] sm_sine_lut = 3'd2;
	localparam [2:0] sm_waiting = 3'd3;
	
	always @(posedge i_Clock) begin
		if (i_Reset) begin
			sp_write <= 1'b0;
			o_Sample_Ready <= 1'b0;
			sample_position <= 1'b0;
			state_machine <= sm_init;
			lut_pos <= 1'b0;
		end
		else begin
			case (state_machine)
				sm_init:
					begin
						accumulated_frequency <= i_Frequency;
						o_Sample_Ready <= 1'b0;
						sp_write <= 1'b0;
						o_Freq_Too_High = 1'b0;
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
						o_Sample_Ready <= 1'b1;
						sp_write <= 1'b0;
						lut_pos <= sample_position[15:5];
						state_machine <= sm_waiting;
					end
					
				sm_waiting:
					// Once sample has been read by top restart
					begin
						if (accumulated_frequency > 20000) begin
							o_Freq_Too_High = 1'b1;
						end
						
						if (i_Next_Sample) begin
							accumulated_frequency <= accumulated_frequency + i_Frequency;
							o_Sample_Ready <= 1'b0;
							state_machine <= (i_Harmonic == 1'b0) ? sm_init : sm_sample_pos;
						end
					end
			endcase
		end
		
	end

endmodule