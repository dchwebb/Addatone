module top
	(
		input wire i_Clock,
		input wire reset_n,
		output reg debug,
		output reg test,
		input wire i_ADC_Data,
		input wire i_ADC_Clock,
		input wire i_ADC_CS,
		output wire o_DAC_MOSI,
		output wire o_DAC_SCK,
		output wire o_DAC_CS
	);
	parameter NO_OF_HARMONICS = 8'd50;

	wire Reset;
	assign Reset = ~reset_n;
	wire Main_Clock;

	// Wrapper for PLL primitive generating 48MHz from 12MHz oscillator
	PLL_Primitive_48MHz pll_48 (.i_Reset(Reset), .i_Clock(i_Clock), .o_PLL_Clock(Main_Clock));
	
	// Sample position RAM - memory array to store current position in cycle of each harmonic
	parameter SAMPLERATE = 16'd48000;
	parameter SAMPLEINTERVAL = 16'd1000;			// Clock frequency / sample rate - eg 48Mhz / 48khz = 1000

	reg [15:0] Sample_Timer = 1'b0;					// Counts up to SAMPLEINTERVAL to set sample rate interval
	reg [7:0] Harmonic = 1'b0;							// Number of harmonic being calculated
	reg Next_Sample;										// Trigger from top module to say current value has been read and ready for next sample
	wire signed [15:0] Sample_Value;
	reg [15:0] Frequency = 16'd90;
	reg [15:0] Freq_Scale = 16'd0;
	reg [7:0] Comb_Interval = 1'd0;
	wire Sample_Ready, Freq_Too_High;
	Sample_Position sample_position(
		.i_Reset(Reset),
		.i_Clock(Main_Clock),
		.i_Frequency(Frequency),
		.i_Freq_Offset(Freq_Scale),
		.i_Harmonic(Harmonic),
		.o_Sample_Ready(Sample_Ready),
		.i_Next_Sample(Next_Sample),
		.o_Sample_Value(Sample_Value),
		.o_Freq_Too_High(Freq_Too_High)
	);
	
	// Initialise ADC SPI input microcontroller
	wire [15:0] ADC_Data[4:0];
	wire ADC_Data_Received;
	ADC_SPI_In adc (
		.i_Reset(Reset),
		.i_Clock(Main_Clock),
		.i_SPI_CS(i_ADC_CS),
		.i_SPI_Clock(i_ADC_Clock),
		.i_SPI_Data(i_ADC_Data),
		.o_Data0(ADC_Data[0]),
		.o_Data1(ADC_Data[1]),
		.o_Data2(ADC_Data[2]),
		.o_Data3(ADC_Data[3]),
		.o_Data4(ADC_Data[4]),
		.o_Data_Received(ADC_Data_Received)
	);

	// Instantiate scaling adder - this scales then accumulates samples for each sine wave
	parameter DIV_BIT = 9;									// Allows fractions from 1/128 to 127/128 (for DIV_BIT = 7)
	reg [DIV_BIT - 1:0] Harmonic_Scale = 270;			// Level at which higher harmonics are attenuated
	reg [DIV_BIT - 1:0] Scale_Initial = 511;
	reg [1:0] Adder_Start;
	wire [1:0] Adder_Ready;
	reg Adder_Clear;
	reg Active_Adder = 1'b0;
	wire [DIV_BIT - 1:0] Adder_Mult;
	wire signed [31:0] Adder_Total[1:0];
	reg signed [31:0] r_Adder_Total[1:0];
	wire [1:0] AdderDebug;

	// Use generate block to create two adders (odd and even harmonics)
	genvar a;
	for (a = 0; a < 2; a = a + 1) begin:genadder
		Adder #(.DIVISOR_BITS(DIV_BIT)) adder (
			.i_Clock(Main_Clock),
			.i_Reset(Reset),
			.i_Start(Adder_Start[a]),
			.i_Clear_Accumulator(Adder_Clear),
			.i_Multiple(Adder_Mult),
			.i_Sample(Sample_Value),
			.o_Accumulator(Adder_Total[a]),
			.o_Done(Adder_Ready[a]),
			.debug(AdderDebug[a])
		);
	end
//	assign debug = Adder_Ready[0];

	// instantiate multiple scaler - this takes incoming ADC reading and uses it to reduce the level of harmonics scaled by the Adder
	reg Start_Mult_Scaler, Reset_Mult_Scaler;
	wire Mult_Ready, Comb_Muted;
	Scale_Mult #(.DIV_BIT(DIV_BIT)) mult (
		.i_Clock(Main_Clock),
		.i_Start(Start_Mult_Scaler),
		.i_Restart(Reset_Mult_Scaler),
		.i_Scale(Harmonic_Scale),
		.i_Initial(Scale_Initial),
		.i_Comb_Interval(Comb_Interval),
		.o_Comb_Muted(Comb_Muted),
		.o_Mult(Adder_Mult),
		.o_Mult_Ready(Mult_Ready)
	);
	// Instantiate Sample Output module which scales output and sends to DAC
	reg DAC_Send;
	reg signed [31:0] Output_Sample;
	Sample_Output sample_output (
		.i_Clock(Main_Clock),
		.i_Reset(Reset),
		.i_Start(DAC_Send),
		.i_Sample_L(r_Adder_Total[0]),
		.i_Sample_R(r_Adder_Total[1]),
		.o_SPI_CS(o_DAC_CS),
		.o_SPI_Clock(o_DAC_SCK),
		.o_SPI_Data(o_DAC_MOSI)
	);


	// State Machine settings - used to control calculation of amplitude of each harmonic sample
	localparam sm_init = 4'd0;
	localparam sm_adder_mult = 4'd1;
	localparam sm_check_mute = 4'd2;
	localparam sm_adder_start = 4'd3;
	localparam sm_adder_wait = 4'd4;
	localparam sm_next_harmonic = 4'd5;
	localparam sm_calc_done = 4'd6;
	localparam sm_ready_to_send = 4'd7;
	reg [3:0] SM_Top = sm_init;

	// Assign values from ADC bytes received to respective control registers
	always @(posedge ADC_Data_Received) begin
		Frequency <= ADC_Data[0];
		Harmonic_Scale <= ADC_Data[1][DIV_BIT - 1:0];			// Rate of attenuation of harmonic scaling (lower means more harmonics)
		Scale_Initial <= ADC_Data[2][DIV_BIT - 1:0];				// Starting value for scaling (lower if there are more harmonics)
		Freq_Scale <= ADC_Data[3];										// Frequency scaling offset - higher frequencies will be moved further from multiple of fundamental
		Comb_Interval <= ADC_Data[4][7:0];							// Comb filter interval - ie which harmonics will muted
		test <= ~test;

	end

	always @(posedge Main_Clock) begin
		if (Reset) begin
			Sample_Timer <= 1'b0;
			DAC_Send <= 1'b0;
			Adder_Start <= 1'b0;
			Harmonic <= 8'b0;
			SM_Top <= sm_init;
		end
		else begin
			Sample_Timer <= Sample_Timer + 1'b1;

			case (SM_Top)
				sm_init:
					begin
						
						DAC_Send <= 1'b0;
						Next_Sample <= 1'b0;
						Adder_Clear <= 1'b0;
						Reset_Mult_Scaler <= 1'b0;
						SM_Top <= sm_adder_start;
					end

				sm_adder_mult:
					// Start the multplier scaler to calculate the harmonic attenuation level and increment the comb filter counter
					begin
						Next_Sample <= 1'b0;
						Adder_Start <= 1'b0;
						Start_Mult_Scaler <= 1'b1;							// decrease harmonic scaler
						SM_Top <= sm_check_mute;
					end

				sm_check_mute:
					begin
						Start_Mult_Scaler <= 1'b0;
						if (Mult_Ready) begin
							//SM_Top <= Comb_Muted ? sm_next_harmonic : sm_adder_start;
							SM_Top <= sm_adder_start;
						end
					end

				sm_adder_start:
					begin
						// Wait until the sample value is ready and then start the next calculation
						if (Sample_Ready) begin
							Adder_Start[Harmonic[0]] <= 1'b1;			// Tell the even/odd adder the next sample is ready
							SM_Top <= sm_adder_wait;
						end
					end

				sm_adder_wait:
					begin
						Active_Adder <= ~Active_Adder;
						Adder_Start <= 1'b0;
						SM_Top <= sm_next_harmonic;
					end

				sm_next_harmonic:
					begin
						Harmonic <= Harmonic + 2'b1;						// Load up next sample position
						Next_Sample <= 1'b1;									// Trigger for sample_position module to start looking up next sample value
						SM_Top <= (Harmonic >= NO_OF_HARMONICS || Freq_Too_High) ? sm_calc_done : sm_adder_mult;
					end

				sm_calc_done:
					begin
						// all harmonics calculated - read accumulated output levels into registers for sending to DAC
						r_Adder_Total[0] <= Adder_Total[0];
						r_Adder_Total[1] <= Adder_Total[1];

						Next_Sample <= 1'b0;
						Adder_Clear <= 1'b1;
						
						SM_Top <= sm_ready_to_send;
					end

				sm_ready_to_send:
					if (Sample_Timer == SAMPLEINTERVAL) begin
						// Send sample value to DAC
						DAC_Send <= 1'b1;

						// Clean state ready for next loop
						Adder_Clear <= 1'b0;
						Sample_Timer <= 1'b0;
						Harmonic <= 8'b0;
						Next_Sample <= 1'b1;
						Reset_Mult_Scaler <= 1'b1;
						Active_Adder <= 1'b0;

						SM_Top <=  sm_init;
					end


			endcase

		end
	end
endmodule