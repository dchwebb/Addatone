`timescale 1ns / 1ns

module TestBench;
	wire [15:0] adc_data0;
	wire [15:0] adc_data1;
	wire adc_data_received;
	reg reset;
	reg SPIClkOut;
	reg SPIDataOut;
	reg SPINssOut;

	wire fpga_clock;
	OSCH #(.NOM_FREQ("133.00")) rc_oscillator(.STDBY(1'b0), .OSC(fpga_clock), .SEDSTDBY());

	ADC_SPI_In adc(.i_reset(reset), .i_clock(fpga_clock), .i_SPI_CS(SPINssOut), .i_SPI_clock(SPIClkOut), .i_SPI_data(SPIDataOut), .o_data0(adc_data0), .o_data1(adc_data1), .o_data_received(adc_data_received));

	reg [15:0] data_packet [3:0];
	integer i;

	task send_SPI;
		input [0:15] packet;
		input [4:0] bitcount;
		begin
			for (i = 0; i < bitcount; i = i + 1) begin
				#375

				SPIDataOut = packet[i];
				#5
				SPIClkOut = 1'b0;
				#375
				SPIClkOut = 1'b1;
			end
			#375
			SPIClkOut = 1'b0;
			SPIDataOut = 1'b0;

		end
	endtask

	initial begin
		data_packet[0] = {16'b00000000_11001000};
		data_packet[1] = {16'b11111110_10101100};
		data_packet[2] = {16'b00000000_01001011};
		data_packet[3] = {16'b01010101_00110011};

		reset = 1'b1;
		SPINssOut = 1'b1;
		SPIClkOut = 1'b0;
		SPIDataOut = 1'b1;
		#20
		reset = 1'b0;
		#10


		SPINssOut = 1'b0;
		send_SPI(data_packet[0], 16);
		send_SPI(data_packet[1], 16);
		SPINssOut = 1'b1;
		#10000
		SPINssOut = 1'b0;
		send_SPI(data_packet[2], 16);
		send_SPI(data_packet[3], 16);
		SPINssOut = 1'b1;
		#10000

		$finish;
	end
endmodule