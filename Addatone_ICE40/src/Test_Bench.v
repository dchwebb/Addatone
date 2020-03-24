`timescale 1ns/1ns

module Test_Bench;

	wire debug, test;
	reg clock = 1'b0;
	reg reset_n = 1'b0;
	wire o_DAC_MOSI, o_DAC_SCK, o_DAC_CS;
	reg i_ADC_Data, i_ADC_Clock, i_ADC_CS;


//	HSOSC	#(.CLKHF_DIV (2'b00)) int_osc (
//		.CLKHFPU (1'b1),  // I
//		.CLKHFEN (1'b1),  // I
//		.CLKHF   (clock)   // O
//	);

	top dut (
		.i_Clock(clock),
		.reset_n(reset_n),
		.debug(debug),
		.test(test),
		.i_ADC_Data(i_ADC_Data),
		.i_ADC_Clock(i_ADC_Clock),
		.i_ADC_CS(i_ADC_CS),
		.o_DAC_MOSI(o_DAC_MOSI),
		.o_DAC_SCK(o_DAC_SCK),
		.o_DAC_CS(o_DAC_CS)
	);

	always
		#41.6666666 clock = !clock;			// 48MHz clock

	initial begin
		reset_n = 1'b0;
		#1000
		reset_n = 1'b1;

		//#10000
		//$finish();
	end
endmodule
