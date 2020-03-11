/*
	Module is responsible for supplying the sample value of each harmonic as incremented by the top module.
	This involves keeping track of the position of each harmonic's current sample in RAM (SamplePos_RAM module),
	incrementing and adding the current frequency to the sample position, then looking up the sample value in the Sine LUT.
	It also applies a frequency offset so higher harmonics can be increasingly detuned.
	This works in two directions - odd harmonics are tuned down and even harmonics tuned up.
*/
module Sample_Position
	(
		input wire i_Reset,
		input wire i_Clock,
		input wire [15:0] i_Frequency,
		input wire [15:0] i_Freq_Scale,			// Offset to allow cumulative frequency shifting of higher harmonics
		input wire [7:0] i_Harmonic,
		output reg o_Sample_Ready,					// Tells top module that sample position has been loaded
		input wire i_Next_Sample,					// Trigger from top module to say current value has been read and ready for next sample
		output wire [15:0] o_Sample_Value,
		output reg o_Freq_Too_High
	);

	reg Sample_Pos_WE;
	wire [15:0] Sample_Pos_Read;
	reg [15:0] Sample_Position;
	reg [10:0] LUT_Pos;

	// Initialise Sample Position RAM (IP)
	SamplePos_RAM sample_pos_ram(.Clock(i_Clock), .ClockEn(1'b1), .Reset(i_Reset), .WE(Sample_Pos_WE), .Address(i_Harmonic), .Data(Sample_Position), .Q(Sample_Pos_Read));

	// Initialise Sine LUT
	SineLUT sin_lut (.Address(LUT_Pos), .OutClock(i_Clock), .OutClockEn(1'b1), .Reset(i_Reset), .Q(o_Sample_Value));

	reg [15:0] Accumulated_Frequency;
	reg [15:0] Accumulated_Freq_Scale;
	reg [2:0] State_Machine;
	localparam [2:0] sm_init = 3'd0;
	localparam [2:0] sm_sample_pos = 3'd1;
	localparam [2:0] sm_sine_lut = 3'd2;
	localparam [2:0] sm_waiting = 3'd3;
	localparam [2:0] sm_offset = 3'd4;
	localparam [2:0] sm_offset2 = 3'd5;
	
	always @(posedge i_Clock) begin
		if (i_Reset) begin
			Sample_Pos_WE <= 1'b0;
			o_Sample_Ready <= 1'b0;
			Sample_Position <= 1'b0;
			o_Freq_Too_High <= 1'b0;
			LUT_Pos <= 1'b0;
			State_Machine <= sm_init;
		end
		else begin
			case (State_Machine)
				sm_init:
					begin
						Accumulated_Frequency <= i_Frequency;
						Accumulated_Freq_Scale <= 1'b0;
						o_Sample_Ready <= 1'b0;
						Sample_Pos_WE <= 1'b0;
						o_Freq_Too_High <= 1'b0;
						State_Machine <= sm_sample_pos;
					end
					
				sm_sample_pos:
					begin
						// increment next sample position by frequency: number of items in sine LUT is 2048 (32*2048=65536) which means that we can divide by 32 to get correct position
						Sample_Position <= Sample_Pos_Read + Accumulated_Frequency;
						Sample_Pos_WE <= 1'b1;
						State_Machine <= sm_sine_lut;
					end

				sm_sine_lut:
					begin
						// sample position is ready pass to sine LUT to get sample value
						o_Sample_Ready <= 1'b1;
						Sample_Pos_WE <= 1'b0;
						LUT_Pos <= Sample_Position[15:5];
						State_Machine <= sm_waiting;
					end
					
				sm_waiting:
					// Once sample has been read by top restart
					begin
						if (Accumulated_Frequency > 20000) begin
							o_Freq_Too_High <= 1'b1;
						end
						
						if (i_Next_Sample) begin
							Accumulated_Frequency <= Accumulated_Frequency + i_Frequency;
							o_Sample_Ready <= 1'b0;
							State_Machine <= sm_offset;
						end
					end
				
				sm_offset:
					begin
						State_Machine <= (i_Harmonic == 1'b0) ? sm_init : sm_sample_pos;
						if (i_Harmonic[0]) begin
							Accumulated_Freq_Scale <= Accumulated_Freq_Scale + i_Freq_Scale;
							Accumulated_Frequency <= Accumulated_Frequency + Accumulated_Freq_Scale;
						end
						else if (Accumulated_Freq_Scale < Accumulated_Frequency)
							State_Machine <= sm_offset2;
					end

				sm_offset2:
					begin
						//Accumulated_Freq_Scale <= Accumulated_Freq_Scale + i_Freq_Scale;
						Accumulated_Frequency <= Accumulated_Frequency - Accumulated_Freq_Scale;
						State_Machine <= (i_Harmonic == 1'b0) ? sm_init : sm_sample_pos;
					end

			endcase
		end
		
	end

endmodule