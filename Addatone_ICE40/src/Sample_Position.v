/*
	Module is responsible for supplying the sample value of each harmonic.
	This involves keeping track of the position of each harmonic's current sample position in RAM (SamplePos_RAM module),
	incrementing and adding the current frequency to the sample position, then looking up the sample value in the Sine LUT.
	It also applies a frequency offset so higher harmonics can be increasingly detuned.
	This works in two directions - odd harmonics are tuned up and even harmonics tuned down.
*/
module Sample_Position
	(
		input wire i_Reset,
		input wire i_Clock,
		input wire [15:0] i_Frequency,
		input wire [15:0] i_Freq_Offset,				// Offset to allow cumulative frequency shifting of higher harmonics
		input wire [7:0] i_Harmonic,
		output reg o_Sample_Ready = 1'b0,			// Tells top module that sample position has been loaded
		input wire i_Next_Sample,						// Trigger from top module to say current value has been read and ready for next sample
		output wire [15:0] o_Sample_Value,
		output reg o_Freq_Too_High
	);

	reg Sample_Pos_WE;
	wire [15:0] Sample_Pos_Read;
	reg [15:0] Sample_Position;
	reg [10:0] LUT_Pos;
	
	// Initialise Sample Position RAM (IP)
	//	SamplePos_RAM sample_pos_ram(.Clock(i_Clock), .ClockEn(1'b1), .Reset(i_Reset), .WE(Sample_Pos_WE), .Address(i_Harmonic), .Data(Sample_Position), .Q(Sample_Pos_Read));
	SamplePos_RAM sp_ram (
		.clk_i(i_Clock),
		.rst_i(i_Reset),
		.clk_en_i(1'b1),
		.wr_en_i(Sample_Pos_WE),
		.wr_data_i(Sample_Position),
		.addr_i(i_Harmonic),
		.rd_data_o(Sample_Pos_Read)
	);
		  
	// Initialise Sine LUT
	//SineLUT sin_lut (.Address(LUT_Pos), .OutClock(i_Clock), .OutClockEn(1'b1), .Reset(i_Reset), .Q(o_Sample_Value));
		Sine_LUT sin_lut (
		.rd_clk_i(i_Clock),
		.rst_i(i_Reset),
		.rd_en_i(1'b1),
		.rd_clk_en_i(1'b1),
		.rd_addr_i(LUT_Pos),
		.rd_data_o(o_Sample_Value)
	);

	reg [15:0] Accumulated_Frequency;
	reg [15:0] Accumulated_Freq_Offset;
	reg signed [15:0] Accumulated_Offset;
	
	localparam [2:0] sm_init = 3'd0;
	localparam [2:0] sm_sample_pos = 3'd1;
	localparam [2:0] sm_sine_lut = 3'd2;
	localparam [2:0] sm_offset = 3'd3;
	localparam [2:0] sm_waiting = 3'd4;
	reg [2:0] SM_Sample_Position = sm_init;

	
	always @(posedge i_Clock) begin
		if (i_Reset) begin
			Sample_Pos_WE <= 1'b0;
			o_Sample_Ready <= 1'b0;
			Sample_Position <= 1'b0;
			o_Freq_Too_High <= 1'b0;
			LUT_Pos <= 1'b0;
			SM_Sample_Position <= sm_init;
		end
		else begin
			case (SM_Sample_Position)
				sm_init:
					begin
						Accumulated_Frequency <= i_Frequency;
						Accumulated_Freq_Offset <= 1'b0;
						o_Sample_Ready <= 1'b0;
						Sample_Pos_WE <= 1'b0;
						o_Freq_Too_High <= 1'b0;
						SM_Sample_Position <= sm_sample_pos;
					end
					
				sm_sample_pos:
					begin
						// increment next sample position by frequency: number of items in sine LUT is 2048 (32*2048=65536) which means that we can divide by 32 to get correct position
						Sample_Position <= Sample_Pos_Read + Accumulated_Frequency;
						Sample_Pos_WE <= 1'b1;
						SM_Sample_Position <= sm_sine_lut;
					end

				sm_sine_lut:
					begin
						// sample position is ready pass to sine LUT to get sample value
						o_Sample_Ready <= 1'b1;
						Sample_Pos_WE <= 1'b0;
						LUT_Pos <= Sample_Position[15:5];
						Accumulated_Offset <= 1'b0;
						SM_Sample_Position <= sm_offset;
						Accumulated_Frequency <= Accumulated_Frequency + i_Frequency;
					end
					
				sm_offset:
					// Apply frequency offset adjustment, checking that when reducing frequency we are not reducing below zero
					begin
						if (i_Harmonic[0])
							Accumulated_Offset <= Accumulated_Freq_Offset;
						else if (Accumulated_Freq_Offset < Accumulated_Frequency)
							Accumulated_Offset <= -Accumulated_Freq_Offset;

						SM_Sample_Position <= sm_waiting;
					end

				sm_waiting:
					// Once sample has been read by top adjust accumulated frequency registers and restart
					begin
						if (Accumulated_Frequency > 20000) begin		// If upper level of frequency is beyond audible frequency tell top to ignore remaining harmonics
							o_Freq_Too_High <= 1'b1;
						end
						
						if (i_Next_Sample) begin
							Accumulated_Frequency <= Accumulated_Frequency + Accumulated_Offset;
							Accumulated_Freq_Offset <= Accumulated_Freq_Offset + i_Freq_Offset;
							//Accumulated_Freq_Offset <= Accumulated_Freq_Offset + 100;
							o_Sample_Ready <= 1'b0;
							SM_Sample_Position <= (i_Harmonic == 1'b0) ? sm_init : sm_sample_pos;
						end
					end
				
			endcase
		end
		
	end

endmodule