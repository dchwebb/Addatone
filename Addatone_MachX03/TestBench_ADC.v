`timescale 1ns / 1ns

module TestBench;
	wire [15:0] data_in;
	wire received;
	reg reset;
	reg SPIClkOut;
	reg SPIDataOut;

	wire fpga_clock;
	OSCH #(.NOM_FREQ("133.00")) rc_oscillator(.STDBY(1'b0), .OSC(fpga_clock), .SEDSTDBY());


	ADC_SPI_In dut(.clock(fpga_clock), .reset(reset), .spi_clock_in(SPIClkOut), .spi_data_in(SPIDataOut), .data_out0(data_in), .data_received(received));
	reg [15:0] data_packet [2:0];
	integer i;

	task send_SPI;
		input [15:0] packet;

		begin
			for (i = 0; i < 16; i = i + 1) begin
				#375
				SPIClkOut = 1'b0;
				SPIDataOut = packet[i];
				#375
				SPIClkOut = 1'b1;
			end
			#375
			SPIClkOut = 1'b0;
			SPIDataOut = 1'b0;
		end
	endtask

	task send_badSPI;
		input [15:0] packet;

		begin
			for (i = 0; i < 15; i = i + 1) begin
				#375
				SPIClkOut = 1'b0;
				SPIDataOut = packet[i];
				#375
				SPIClkOut = 1'b1;
			end
			#375
			SPIClkOut = 1'b0;
			SPIDataOut = 1'b0;
		end
	endtask

	initial begin
		data_packet[0] = {16'b10010110_10101010};
		data_packet[1] = {16'b10101010_11001100};	//0xaacc
		data_packet[2] = {16'b00010110_01010101};

		reset = 1'b1;
		SPIClkOut = 1'b0;
		SPIDataOut = 1'b0;
		#20
		reset = 1'b0;
		#10



		send_badSPI(data_packet[0]);
		#10000
		send_SPI(data_packet[1]);
		#100000
		send_SPI(data_packet[2]);
		#100000

		$finish;
	end
endmodule