module DAC_SPI_Out (clock_in, reset, data_in, send, spi_cs_out, spi_clock_out, spi_data_out);
	input wire clock_in;
	input wire reset;
	input wire [23:0] data_in;
	input wire send;
	output reg spi_cs_out;
	output reg spi_clock_out;
	output reg spi_data_out;

	reg [0:23] data_to_send;
	reg [4:0] current_bit;

	reg [7:0] clock_counter;
	parameter CLOCKCOUNT = 4'd10;			// number of internal clock events between each SPI clock transition

	reg [2:0] dac_state;
	parameter dac_state_idle = 2'b00;
	parameter dac_state_sending = 2'b01;
	parameter dac_state_sent = 2'b10;
	parameter dac_state_cs_pulse = 2'b11;

	initial begin
		dac_state = dac_state_idle;
		spi_cs_out = 1'b1;
		spi_data_out = 1'b0;
		spi_clock_out = 1'b1;
		clock_counter = 1'b0;
	end


	always @(posedge clock_in) begin
		if (reset) begin
			dac_state <= dac_state_idle;
			spi_cs_out <= 1'b1;
			spi_data_out <= 1'b0;
			spi_clock_out <= 1'b1;
			clock_counter <= 1'b0;
		end
		else if (clock_counter == 0) begin		// only transition state on first clock counter - otherwise increment SPI clock
			if (dac_state != dac_state_idle) begin
				clock_counter <= 1'b1;
			end

			case (dac_state)
				dac_state_idle:
					if (send) begin
						dac_state <= dac_state_sending;
						spi_cs_out <= 1'b0;
						data_to_send <= data_in;
						current_bit <= 1'b0;
					end
				dac_state_sending:
					begin
						if (current_bit == 23)
							dac_state <= dac_state_sent;
						spi_data_out <= data_to_send[current_bit];
						current_bit <= current_bit + 1'b1;
						spi_clock_out <= 1'b1;
					end
				dac_state_sent:
					begin
						spi_cs_out <= 1'b1;
						spi_data_out <= 1'b0;
						dac_state <= dac_state_cs_pulse;
						spi_clock_out <= 1;
					end
				dac_state_cs_pulse:
					begin
						//spi_clock_out <= 1;
						dac_state <= dac_state_idle;
					end

			endcase
		end
		else begin												// transition SPI clock
			if (clock_counter == (2 * CLOCKCOUNT) - 1) begin
				clock_counter <= 0;
			end
			else begin
				if (clock_counter == CLOCKCOUNT && dac_state != dac_state_cs_pulse && dac_state != dac_state_idle) begin
					spi_clock_out <= 0;
				end
				clock_counter <= clock_counter + 1'b1;
			end
		end
	end

endmodule
