module ADC_SPI_In
#(parameter RECEIVEBYTES = 2)
	(
		input wire i_reset,
		input wire i_clock,
		input wire i_SPI_CS,
		input wire i_SPI_clock,
		input wire i_SPI_data,
		output wire [15:0] o_data0,
		output wire [15:0] o_data1,
		output reg o_data_received
	);

	reg [3:0] receive_bit;
	reg [1:0] receive_byte;
	reg [0:15] bytes_in[$clog2(RECEIVEBYTES):0];

	reg [1:0] SPISlaveState;
	localparam state_waiting = 2'b00;
	localparam state_receiving = 2'b01;

	// Settings to clean noise on SPI line
	reg [5:0] clock_counter;
	reg nss_change;
	reg nss_stable;

	// Check for false triggers using main clock to count negative clock pulses and noise on the nss line
	always @(posedge i_clock) begin
		if (i_SPI_clock) begin
			clock_counter <= 1'b0;
		end
		else begin
			clock_counter <= clock_counter + 1'b1;		// count negative spi clock duration to eliminate noise
		end

		if (i_SPI_CS != nss_stable) begin
			if (nss_change) begin
				nss_stable <= i_SPI_CS;
				nss_change <= 1'b0;
			end
			else
				nss_change <= 1'b1;
		end
		else
			nss_change <= 1'b0;
	end


	always @(posedge i_SPI_clock or posedge nss_stable or posedge i_reset) begin
		if (nss_stable || i_reset) begin
			SPISlaveState <= state_waiting;
		end
		else if (clock_counter > 2) begin		//  check there have been at least two counts of negative pulse before recording a valid SPI clock cycle
			case (SPISlaveState)
				state_waiting:
					begin
						SPISlaveState <= state_receiving;
						receive_byte <= 1'b0;
						receive_bit <= 1'b1;
						o_data_received <= 1'b0;
						bytes_in[0][0] <= i_SPI_data;
					end

				state_receiving:
					begin
						bytes_in[receive_byte][receive_bit] <= i_SPI_data;
						receive_bit <= receive_bit + 1'b1;
						
						if (receive_bit == 15) begin								// Byte received
							receive_byte <= receive_byte + 1'b1;
							if (receive_byte == RECEIVEBYTES - 1) begin		// If all bytes received set state back to waiting and activate received flag
								SPISlaveState <= state_waiting;
								o_data_received <= 1'b1;
								receive_byte <= 1'b0;
							end
							else begin
								receive_bit <= 0;
							end
						end
					end

			endcase
		end
	end

	// Output bytes are continously assigned but only valid when received flag is high
	assign o_data0 = bytes_in[0];
	assign o_data1 = bytes_in[1];
endmodule