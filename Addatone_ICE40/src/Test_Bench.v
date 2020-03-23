`timescale 1ns/1ns

module Test_Bench;

	//SB_HFOSC OSCInst0 (
		//.CLKHFEN(ENCLKHF),
		//.CLKHFPU(CLKHF_POWERUP),
		//.CLKHF(CLKHF)
	//);

	//defparam OSCInst0.CLKHF_DIV = 2'b00;

	wire led, test;
	reg clock = 1'b0;
	reg reset_n = 1'b0;
	wire o_DAC_MOSI, o_DAC_SCK, o_DAC_CS;

	top dut (
		//.i_Clock(clock),
		.reset_n(reset_n),
		.led(led),
		.test(test),
		.o_DAC_MOSI(o_DAC_MOSI),
		.o_DAC_SCK(o_DAC_SCK),
		.o_DAC_CS(o_DAC_CS)
	);

	always
		#41.6666666 clock = !clock;			// 12MHz clock

	initial begin
		reset_n = 1'b0;
		#1000
		reset_n = 1'b1;

		//#10000
		//$finish();
	end
endmodule
