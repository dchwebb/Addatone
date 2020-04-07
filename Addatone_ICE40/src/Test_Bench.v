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

	reg [15:0] data_packet [4:0];
	integer i, p;

	task Send_ADC;
	//	input [0:15] packet;

		begin
			i_ADC_CS = 1'b0;
			for (p = 0; p < 5; p = p + 1) begin
				for (i = 16; i > 0; i = i - 1) begin
					#375
					i_ADC_Clock <= 1'b0;
					i_ADC_Data <= data_packet[p][i - 1];
					#375
					i_ADC_Clock <= 1'b1;
				end
			end
			#375
			i_ADC_Clock = 1'b0;
			i_ADC_Data = 1'b0;
			i_ADC_CS = 1'b1;
		end
	endtask

	reg signed [11:0] mult1 = 11'd1234;
	reg signed [15:0] mult2 = -16'sd22111;
	reg signed [27:0] mult_result = 1'b0;


	always
		#41.6666666 clock = !clock;			// 48MHz clock

	initial begin
		i_ADC_CS = 1'b1;
		i_ADC_Clock = 1'b0;
		i_ADC_Data = 1'b0;
		mult_result = mult2 * mult1;

		data_packet[0] = {16'h007B};
		data_packet[1] = {16'h0067};
		data_packet[2] = {16'd506};
		data_packet[3] = {16'h0000};
		data_packet[4] = {16'h0000};

		reset_n = 1'b0;
		#1000
		reset_n = 1'b1;
		mult_result = mult2 * $signed({5'b00000, mult1});

		#50
		Send_ADC();

		//#10000
		//$finish();
	end
endmodule
