`timescale 1ns / 1ns

module TestBench_Top;

	// DAC settings
	wire spi_clock_out;
	wire spi_data_out;
	wire spi_cs_out;

	// ADC settings
	reg spi_clock_in;
	reg spi_data_in;

	reg reset;
	wire rstn;       // from SW1 pushbutton
	assign rstn = ~reset;

	GSR GSR_INST (.GSR(1'b1));
	PUR PUR_INST (.PUR(1'b1));

	wire osc_clock;
	OSCH #(.NOM_FREQ("12.09")) rc_oscillator(.STDBY(1'b0), .OSC(osc_clock), .SEDSTDBY());

	top #(.SAMPLEINTERVAL(30)) dut(.dac_spi_cs(spi_cs_out), .dac_spi_data(spi_data_out), .dac_spi_clock(spi_clock_out), .adc_spi_data(spi_data_in), .adc_spi_clock(spi_clock_in), .rstn(rstn), .crystal_osc(osc_clock));

	reg [15:0] data_packet [2:0];
	integer i;

	task send_SPI;
		input [0:15] packet;

		begin
			for (i = 0; i < 16; i = i + 1) begin
				#375
				spi_clock_in <= 1'b0;
				spi_data_in <= packet[i];
				#375
				spi_clock_in <= 1'b1;
				$display("Showing %d value\n", i);

			end
			#375
			spi_clock_in = 1'b0;
			spi_data_in = 1'b0;
		end
	endtask

	task send_badSPI;
		input [0:15] packet;

		begin
			for (i = 0; i < 15; i = i + 1) begin
				#375
				spi_clock_in <= 1'b0;
				spi_data_in <= packet[i];
				#375
				spi_clock_in = 1'b1;
			end
			#375
			spi_clock_in = 1'b0;
			spi_data_in = 1'b0;
		end
	endtask

	initial begin
		data_packet[0] = {16'b10010110_10101010};
		data_packet[1] = {16'b01010101_00110011};	//0xaacc
		data_packet[2] = {16'b00010110_01010101};

		$monitor("Starting simulation display\n");

		reset = 1'b1;
		spi_clock_in = 1'b0;
		spi_data_in = 1'b0;
		#20
		reset = 1'b0;
//		#100


		//send_badSPI(data_packet[0]);
//		#10000
		//send_SPI(data_packet[1]);
//		#100000
		//send_SPI(data_packet[2]);
//		#100000

//		$finish;

	end

endmodule