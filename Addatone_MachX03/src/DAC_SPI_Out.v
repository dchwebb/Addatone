module DAC_SPI_Out
	(
		input wire i_clock,
		input wire i_reset,
		input wire [23:0] i_data,
		input wire i_send,
		output reg o_SPI_CS,
		output reg o_SPI_clock,
		output reg o_SPI_data,
		output reg o_Ready
	);
	
	reg [0:23] data_to_send;
	reg [4:0] current_bit;

	reg [7:0] clock_counter;
	parameter CLOCKCOUNT = 4'd10;			// number of internal clock events between each SPI clock transition

	reg [1:0] dac_state;
	parameter dac_state_idle = 2'd0;
	parameter dac_state_sending = 2'd1;
	parameter dac_state_sent = 2'd2;
	parameter dac_state_cs_pulse = 2'd3;

	//initial begin
		//dac_state = dac_state_idle;
		//o_Ready = 1'b1;
		//o_SPI_CS = 1'b1;
		//o_SPI_data = 1'b0;
		//o_SPI_clock = 1'b1;
		//clock_counter = 1'b0;
	//end

	always @(posedge i_clock) begin
		if (i_reset) begin
			o_SPI_CS <= 1'b1;
			o_SPI_data <= 1'b0;
			o_SPI_clock <= 1'b1;
			clock_counter <= 1'b0;
			o_Ready <= 1'b1;
			dac_state <= dac_state_idle;

		end
		else if (clock_counter == 0) begin		// only transition state on first clock counter - otherwise increment SPI clock
			if (dac_state != dac_state_idle) begin
				clock_counter <= 1'b1;
			end
			
			if (i_send)
				o_Ready <= 1'b0;

			case (dac_state)
				dac_state_idle:
					begin
						o_Ready <= 1'b1;
						if (i_send) begin
							o_Ready <= 1'b0;
							o_SPI_CS <= 1'b0;
							data_to_send <= i_data;
							current_bit <= 1'b0;
							dac_state <= dac_state_sending;
						end
					end
					
				dac_state_sending:
					begin
						if (current_bit == 23)
							dac_state <= dac_state_sent;
						o_SPI_data <= data_to_send[current_bit];
						current_bit <= current_bit + 1'b1;
						o_SPI_clock <= 1'b1;
					end
					
				dac_state_sent:
					begin
						o_SPI_CS <= 1'b1;
						o_SPI_data <= 1'b0;
						o_SPI_clock <= 1'b1;
						dac_state <= dac_state_cs_pulse;
					end
					
				dac_state_cs_pulse:
					begin
						o_Ready <= 1'b1;
						clock_counter <= 1'b0;
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
					o_SPI_clock <= 0;
				end
				clock_counter <= clock_counter + 1'b1;
			end
		end
	end

endmodule
