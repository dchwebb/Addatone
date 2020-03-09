module ADC_SPI_In
#(parameter RECEIVEBYTES = 3)
	(
		input wire i_reset,
		input wire i_clock,
		input wire i_SPI_CS,
		input wire i_SPI_clock,
		input wire i_SPI_data,
		output wire [15:0] o_data0,
		output wire [15:0] o_data1,
		output wire [15:0] o_data2,
		output reg o_data_received
	);

	reg [3:0] receive_bit;
	reg [1:0] receive_byte;
	reg [0:15] bytes_in[RECEIVEBYTES:0];

	reg SPISlaveState;
	localparam state_waiting = 2'd0;
	localparam state_receiving = 2'd1;

	// Settings to clean noise on SPI line
	reg clock_state;
	reg clock_stable;
	reg CS_state;
	reg CS_stable;
	reg data_state;
	reg [2:0] count_stable;

	// Check for false triggers using main clock to count three stable measures on clock, data and CS
	always @(posedge i_clock) begin
		if (i_reset)
			CS_stable <= 1'b1;
		else begin
			if (i_SPI_clock != clock_state) begin
				clock_state <= i_SPI_clock;
			end
			if (i_SPI_data != data_state) begin
				data_state <= i_SPI_data;
			end
			if (i_SPI_CS != CS_state) begin
				CS_state <= i_SPI_CS;
			end

			if (i_SPI_clock == clock_state && i_SPI_data == data_state && i_SPI_CS == CS_state) begin
				count_stable <= count_stable + 1'b1;
				if (count_stable == 2) begin
					CS_stable <= i_SPI_CS;
					clock_stable <= i_SPI_clock;
				end
			end
			else begin
				count_stable <= 1'b0;
			end
		end
	end


	always @(posedge clock_stable or posedge CS_stable) begin
		if (CS_stable) begin
			SPISlaveState <= state_waiting;
		end
		else begin		//  check there have been at least two counts of negative pulse before recording a valid SPI clock cycle
			case (SPISlaveState)
				state_waiting:
					begin
						SPISlaveState <= state_receiving;
						receive_byte <= 1'b0;
						receive_bit <= 1'b1;
						o_data_received <= 1'b0;
						bytes_in[0][0] <= data_state;
					end

				state_receiving:
					begin
						bytes_in[receive_byte][receive_bit] <= data_state;
						receive_bit <= receive_bit + 1'b1;

						if (receive_bit == 15) begin								// Byte received
							receive_byte <= receive_byte + 1'b1;
							if (receive_byte == RECEIVEBYTES - 1) begin		// If all bytes received set state back to waiting and activate received flag
								o_data_received <= 1'b1;
								receive_byte <= 1'b0;
								SPISlaveState <= state_waiting;
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
	assign o_data2 = bytes_in[2];
endmodule