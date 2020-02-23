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
		output reg o_data_received,
		output reg CS_stable
	);

	reg [3:0] receive_bit;
	reg [1:0] receive_byte;
	reg [0:15] bytes_in[$clog2(RECEIVEBYTES):0];

	reg [1:0] SPISlaveState;
	localparam state_waiting = 2'b00;
	localparam state_receiving = 2'b01;

	// Settings to clean noise on SPI line
	reg [5:0] pos_clock_counter;
	reg [5:0] neg_clock_counter;
	reg bit_read;
	reg bit_ready;
	reg CS_change;
	//reg CS_stable;

	// Check for false triggers using main clock to count negative clock pulses and noise on the nss line
	always @(posedge i_clock) begin
		if (i_reset) begin
			neg_clock_counter <= 1'b0;
			pos_clock_counter <= 1'b0;
			bit_ready = 1'b0;
		end
		else begin

			if (i_SPI_clock) begin
				neg_clock_counter <= 1'b0;
				if (pos_clock_counter > 1'b0 && bit_read == i_SPI_data && !bit_ready) begin
					bit_ready = 1'b1;
				end

				pos_clock_counter <= pos_clock_counter + 1'b1;
				bit_read <= i_SPI_data;
			end
			else begin
				neg_clock_counter <= neg_clock_counter + 1'b1;		// count negative spi clock duration to eliminate noise
				if (neg_clock_counter > 0) begin
					pos_clock_counter <= 1'b0;
					bit_read <= 1'bx;
					bit_ready = 1'b0;
				end
			end

			if (i_SPI_CS != CS_stable) begin
				if (CS_change) begin
					CS_stable <= i_SPI_CS;
					CS_change <= 1'b0;
				end
				else
					CS_change <= 1'b1;
			end
			else
				CS_change <= 1'b0;
		end
	end


	always @(posedge bit_ready or posedge CS_stable or posedge i_reset) begin
		if (CS_stable || i_reset) begin
			SPISlaveState <= state_waiting;
			//receive_byte <= 1'b0;
			//receive_bit <= 1'b0;
			//bytes_in[0] = 1'b0;
			//bytes_in[1] = 1'b0;
		end
		else begin		//  check there have been at least two counts of negative pulse before recording a valid SPI clock cycle
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