module top
	(
		output wire dac_cs,
		output wire dac_bit,
		output wire dac_clock,
		input wire adc_cs,
		input wire adc_data,
		input wire adc_clock,
		input wire rstn,
		input wire crystal_osc,
		output wire err_out,
		output reg debug_out
	);

	parameter NO_OF_HARMONICS = 8'd50;

	wire Reset;
	assign Reset = ~rstn;

	//	Initialise 72MHz PLL clock from dev board 12 MHz crystal (dev board pin C8)
	wire Main_Clock;
	OscPll pll (
		.CLKI(crystal_osc),
		.CLKOP(Main_Clock)
	);

	// Sample position RAM - memory array to store current position in cycle of each harmonic
	parameter SAMPLERATE = 16'd48000;
	parameter SAMPLEINTERVAL = 16'd1500;			// Clock frequency / sample rate - eg 88.67Mhz / 44khz = 2015 OR 72MHz / 48kHz = 1500

	reg [15:0] Sample_Timer = 1'b0;					// Counts up to SAMPLEINTERVAL to set sample rate interval
	reg [7:0] Harmonic = 1'b0;						// Number of harmonic being calculated
	reg Next_Sample;										// Trigger from top module to say current value has been read and ready for next sample
	wire signed [15:0] Sample_Value;
	reg [15:0] Frequency = 16'd50;
	reg [15:0] Freq_Scale = 16'd120;
	reg [15:0] Comb_Interval = 16'd0;
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
		.i_SPI_CS(adc_cs),
		.i_SPI_Clock(adc_clock),
		.i_SPI_Data(adc_data),
		.o_Data0(ADC_Data[0]),
		.o_Data1(ADC_Data[1]),
		.o_Data2(ADC_Data[2]),
		.o_Data3(ADC_Data[3]),
		//.o_Data4(ADC_Data[4]),
		.o_Data_Received(ADC_Data_Received)
	);

	// Instantiate scaling adder - this scales then accumulates samples for each sine wave
	parameter DIV_BIT = 9;									// Allows fractions from 1/128 to 127/128 (for DIV_BIT = 7)
	reg Adder1_Start, Adder2_Start, Adder_Clear;
	reg [DIV_BIT - 1:0] Harmonic_Scale = 270;		// Level at which higher harmonics are attenuated
	reg [DIV_BIT - 1:0] Scale_Initial = 511;
	wire Adder1_Ready, Adder2_Ready;
	wire [DIV_BIT - 1:0] Adder_Mult;
	wire signed [31:0] Adder1_Total;
	wire signed [31:0] Adder2_Total;
	reg signed [31:0] r_Adder1_Total;
	reg signed [31:0] r_Adder2_Total;
	Adder #(.DIVISOR_BITS(DIV_BIT)) adder1 (.i_Clock(Main_Clock), .i_Reset(Reset), .i_Start(Adder1_Start), .i_Clear_Accumulator(Adder_Clear), .i_Multiple(Adder_Mult), .i_Sample(Sample_Value), .o_Accumulator(Adder1_Total), .o_Done(Adder1_Ready));
	Adder #(.DIVISOR_BITS(DIV_BIT)) adder2 (.i_Clock(Main_Clock), .i_Reset(Reset), .i_Start(Adder2_Start), .i_Clear_Accumulator(Adder_Clear), .i_Multiple(Adder_Mult), .i_Sample(Sample_Value), .o_Accumulator(Adder2_Total), .o_Done(Adder2_Ready));

	// instantiate multiple scaler - this takes incoming ADC reading and uses it to reduce the level of harmonics scaled by the Adder
	reg Start_Mult_Scaler, Reset_Mult_Scaler;
	Scale_Mult #(.DIV_BIT(DIV_BIT)) mult (
		.i_Clock(Main_Clock),
		.i_Start(Start_Mult_Scaler),
		.i_Restart(Reset_Mult_Scaler),
		.i_Scale(Harmonic_Scale),
		.i_Initial(Scale_Initial),
		.o_Mult(Adder_Mult)
	);

	// Instantiate Sample Output module which scales output and sends to DAC
	reg DAC_Send;
	reg signed [31:0] Output_Sample;
	Sample_Output sample_output (
		.i_Clock(Main_Clock),
		.i_Reset(Reset),
		.i_Start(DAC_Send),
		.i_Sample_L(r_Adder1_Total),
		.i_Sample_R(r_Adder2_Total),
		.o_SPI_CS(dac_cs),
		.o_SPI_Clock(dac_clock),
		.o_SPI_Data(dac_bit)
	);


	// State Machine settings - used to control calculation of amplitude of each harmonic sample
	reg [3:0] SM_Top;
	localparam sm_init = 4'd1;
	localparam sm_adder_mult = 4'd2;
	localparam sm_scale = 4'd9;
	localparam sm_sine_lookup = 4'd3;
	localparam sm_adder_start = 4'd4;
	localparam sm_adder_wait = 4'd5;
	localparam sm_calc_done = 4'd6;
	localparam sm_scale_sample = 4'd7;
	localparam sm_ready_to_send = 4'd8;
	localparam sm_cleanup = 4'd9;

	always @(posedge ADC_Data_Received) begin
		Frequency <= ADC_Data[0];
		Harmonic_Scale <= ADC_Data[1][DIV_BIT - 1:0];			// Rate of attenuation of harmonic scaling (lower means more harmonics)
		Scale_Initial <= ADC_Data[2][DIV_BIT - 1:0];			// Starting value for scaling (lower if there are more harmonics)
		Freq_Scale <= ADC_Data[3];									// Frequency scaling offset - higher frequencies will be moved further from multiple of fundamental
		Comb_Interval <= ADC_Data[4];								// Comb filter interval - ie which harmonics will muted
		debug_out <= ~debug_out;
	end

	assign err_out = DAC_Send;
	
	always @(posedge Main_Clock) begin
		if (Reset) begin
			Sample_Timer <= 1'b0;
			DAC_Send <= 1'b0;
			Adder1_Start <= 1'b0;
			Adder2_Start <= 1'b0;
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
				begin
					Next_Sample <= 1'b0;
					Adder1_Start <= 1'b0;
					Adder2_Start <= 1'b0;

					// decrease harmonic scaler
					Start_Mult_Scaler <= 1'b1;
					SM_Top <= sm_adder_start;
				end

				sm_adder_start:
				begin
					Start_Mult_Scaler <= 1'b0;

					// Wait until the sample value is ready and Adder is free and then start the next calculation
					if (Sample_Ready && (Harmonic[0] == 1'b0 ? Adder1_Ready : Adder2_Ready)) begin
					//if (Sample_Ready && Adder1_Ready) begin
						Harmonic <= Harmonic + 2'b1;								// Load up next sample position
						Next_Sample <= 1'b1;
						Adder1_Start <= 1'b1;

						if (Harmonic[0] == 1'b0)		// even harmonics
							Adder1_Start <= 1'b1;											// Tell the adder the next sample is ready
						else
							Adder2_Start <= 1'b1;
						SM_Top <= (Harmonic >= NO_OF_HARMONICS || Freq_Too_High) ? sm_adder_wait : sm_adder_mult;
					end
				end

				sm_adder_wait:
				begin
					Next_Sample <= 1'b0;
					Adder1_Start <= 1'b0;
					Adder2_Start <= 1'b0;
					SM_Top <= sm_calc_done;								// Pause to let adder clear adder_Ready state
				end

				sm_calc_done:
				begin
					if (Adder1_Ready && Adder2_Ready) begin
						// all harmonics calculated - offset output for sending to DAC
						//Output_Sample <= 32'h31000 + Adder2_Total;			// Add extra 2^18 (approx) to cancel divide by 4 on final value
						r_Adder1_Total <= Adder1_Total;
						r_Adder2_Total <= Adder2_Total;
						SM_Top <= sm_scale_sample;
					end
				end

				sm_scale_sample:
				begin
					Adder_Clear <= 1'b1;
					SM_Top <= sm_cleanup;
				end
				
				sm_cleanup:
					begin
						Adder_Clear <= 1'b0;
						SM_Top <= sm_ready_to_send;
					end
					
				sm_ready_to_send:
					if (Sample_Timer == SAMPLEINTERVAL) begin
						// Send sample value to DAC
						DAC_Send <= 1'b1;

						// Clean state ready for next loop
						Sample_Timer <= 1'b0;
						Harmonic <= 8'b0;
						Next_Sample <= 1'b1;
						
						Reset_Mult_Scaler <= 1'b1;
						SM_Top <=  sm_init;
					end
				

			endcase

		end
	end

endmodule