`timescale 1ns / 1ns

module TestBench_DAC;

	wire spi_clock;
	wire spi_data;
	wire spi_cs;
	reg send;
	reg reset;
	reg [23:0] dac_data;

	wire fpga_clock;
	OSCH #(.NOM_FREQ("133.00")) rc_oscillator(.STDBY(1'b0), .OSC(fpga_clock));

	DAC_SPI_Out dac(.clock_in(fpga_clock), .reset(reset), .data_in(dac_data), .send(send), .spi_cs_out(spi_cs), .spi_clock_out(spi_clock), .spi_data_out(spi_data));

	initial
	begin
		reset = 1'b1;
		send = 1'b0;
		dac_data = {8'b00110001, 16'b10101010_11001100};
		#20
		reset = 1'b0;
		#20
		@(posedge fpga_clock);
		send = 1'b1;
		@(posedge fpga_clock);
		send = 1'b0;
		#2000
		@(posedge fpga_clock);
		dac_data = 24'b10110001_01010101_11001101;
		send = 1'b1;
		@(posedge fpga_clock);
		send = 1'b0;
		#2000
		$finish;
	end

endmodule
