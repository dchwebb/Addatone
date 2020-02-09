module ADC_SPI_In (reset, clock, spi_nss, spi_clock_in, spi_data_in, data_out, data_received);

	input wire reset;
	input wire clock;
	input wire spi_nss;
	input wire spi_clock_in;
	input wire spi_data_in;
	output reg [0:15] data_out;
	output reg data_received;
	reg [3:0] receive_bit;
	
	reg [1:0] SPISlaveState;
	parameter state_waiting = 2'b00;
	parameter state_receiving = 2'b01;
	parameter state_received = 2'b10;

	reg [5:0] clock_counter;
	reg nss_change;
	reg nss_stable;
	
	// Check for false triggers using main clock to count negative clock pulses and noise on the nss line
	always @(posedge clock) begin
		if (spi_clock_in) begin
			clock_counter <= 1'b0;
		end
		else begin
			clock_counter <= clock_counter + 1'b1;		// count negative spi clock duration to eliminate noise
		end
		
		if (spi_nss != nss_stable) begin
			if (nss_change) begin
				nss_stable <= spi_nss;
				nss_change <= 1'b0;
			end
			else
				nss_change <= 1'b1;
		end
		else
			nss_change <= 1'b0;
	end
	
	
	always @(posedge spi_clock_in or posedge nss_stable or posedge reset) begin
		if (nss_stable || reset) begin
			SPISlaveState <= state_waiting;
		end
		else if (clock_counter > 2) begin		//  check there have been at least two counts of negative pulse before recording a valid SPI clock cycle
			case (SPISlaveState)
				state_waiting:
					begin
						SPISlaveState <= state_receiving;
						receive_bit <= 1'b1;
						data_received <= 1'b0;
						data_out[0] <= spi_data_in;
					end

				state_receiving:
					begin
						data_out[receive_bit] <= spi_data_in;
						receive_bit <= receive_bit + 1'b1;
						if (receive_bit == 15) begin
							SPISlaveState <= state_received;
							data_received <= 1'b1;
						end
					end

				state_received:
					begin
						data_received <= 1'b1;
						SPISlaveState <= state_waiting;
					end
			endcase
		end
	end

endmodule