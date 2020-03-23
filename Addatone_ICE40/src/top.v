module top
	(
		input wire i_Clock,
		input wire reset_n,
		output reg led,
		output reg test,
		input wire i_ADC_Data,
		input wire i_ADC_Clock,
		input wire i_ADC_CS,
		output wire o_DAC_MOSI,
		output wire o_DAC_SCK,
		output wire o_DAC_CS
	);

	wire Reset;
	assign Reset = ~reset_n;
	wire Clock_48MHz;

	PLL_48MHz pll_48 (.ref_clk_i(i_Clock), .rst_n_i(reset_n), .outcore_o(Clock_48MHz), .outglobal_o());
	
	//HSOSC	#(.CLKHF_DIV (2'b01)) int_osc (
		//.CLKHFPU (1'b1),  // I
		//.CLKHFEN (1'b1),  // I
		//.CLKHF   (Clock_48MHz)   // O
	//);

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

	// Initialise ADC SPI input microcontroller
	wire [15:0] ADC_Data[4:0];
	wire ADC_Data_Received;
	ADC_SPI_In adc (
		.i_Reset(Reset),
		.i_Clock(Clock_48MHz),
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
	reg [DIV_BIT - 1:0] Harmonic_Scale = 270;		// Level at which higher harmonics are attenuated
	reg [DIV_BIT - 1:0] Scale_Initial = 511;
	reg [1:0] Adder_Start;
	wire [1:0] Adder_Ready;
	reg Adder_Clear;
	reg Active_Adder = 1'b0;
	wire [DIV_BIT - 1:0] Adder_Mult;
	wire signed [31:0] Adder_Total[1:0];
	reg signed [31:0] r_Adder_Total[1:0];

	reg DAC_Send;
	reg [23:0] DAC_Data;
	wire DAC_Ready;
	
	DAC_SPI_Out dac(
		.i_Clock(Clock_48MHz),
		.i_Reset(Reset),
		.i_Data(DAC_Data),
		.i_Send(DAC_Send),
		.o_SPI_CS(o_DAC_CS),
		.o_SPI_Clock(o_DAC_SCK),
		.o_SPI_Data(o_DAC_MOSI),
		.o_Ready(DAC_Ready)
	);


	reg [8:0] counter = 1'b0;
	reg [10:0] outcount = 1'b0;

	// Assign values from ADC bytes received to respective control registers
	always @(posedge ADC_Data_Received) begin
		Frequency <= ADC_Data[0];
		Harmonic_Scale <= ADC_Data[1][DIV_BIT - 1:0];			// Rate of attenuation of harmonic scaling (lower means more harmonics)
		Scale_Initial <= ADC_Data[2][DIV_BIT - 1:0];				// Starting value for scaling (lower if there are more harmonics)
		Freq_Scale <= ADC_Data[3];										// Frequency scaling offset - higher frequencies will be moved further from multiple of fundamental
		Comb_Interval <= ADC_Data[4][7:0];							// Comb filter interval - ie which harmonics will muted
		test <= ~test;
	end

	wire [15:0] o_Sample_Value;
	Sine_LUT __(
		.rd_clk_i(Clock_48MHz),
		.rst_i(Reset),
		.rd_en_i(1'b1),
		.rd_clk_en_i(1'b1),
		.rd_addr_i(outcount),
		.rd_data_o(o_Sample_Value)
	);

	always @(posedge Clock_48MHz) begin
		if (Reset) begin
			counter <= 1'b0;
			outcount <= 1'b0;
			DAC_Send <= 1'b0;
			led <= 1'b0;
		end
		else begin

			counter <= counter + 1'b1;
			


			if (counter == 100 && DAC_Ready) begin
				outcount <= outcount + 1'b1;
				DAC_Data <= {8'h31, o_Sample_Value};
				DAC_Send <= 1'b1;
			end
			else begin
				DAC_Send <= 1'b0;
			end

			if (counter > 16'd2000)
				led <= 1'b1;
			else
				led <= 1'b0;
		end
	end
endmodule