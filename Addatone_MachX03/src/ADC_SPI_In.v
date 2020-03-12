/*
	Receives scaled and cleaned CV data from Microcontroller ADC using SPI
*/
module ADC_SPI_In
#(parameter RECEIVEBYTES = 4)
	(
		input wire i_Reset,
		input wire i_Clock,
		input wire i_SPI_CS,
		input wire i_SPI_Clock,
		input wire i_SPI_Data,
		output wire [15:0] o_Data0,
		output wire [15:0] o_Data1,
		output wire [15:0] o_Data2,
		output wire [15:0] o_Data3,
		output reg o_Data_Received
	);

	reg [3:0] Receive_Bit;
	reg [1:0] Receive_Byte;
	reg [0:15] r_Bytes_In[RECEIVEBYTES:0];

	reg SM_ADC_In;
	localparam sm_waiting = 2'd0;
	localparam sm_receiving = 2'd1;

	// Settings to clean noise on SPI line
	reg Clock_State;
	reg Clock_Stable;
	reg CS_State;
	reg CS_Stable;
	reg Data_State;
	reg [2:0] Count_Stable;

	// Output bytes are continously assigned but only valid when received flag is high
	assign o_Data0 = r_Bytes_In[0];
	assign o_Data1 = r_Bytes_In[1];
	assign o_Data2 = r_Bytes_In[2];
	assign o_Data3 = r_Bytes_In[3];

	// Check for false triggers using main clock to count three stable measures on clock, data and CS
	always @(posedge i_Clock) begin
		if (i_Reset)
			CS_Stable <= 1'b1;
		else begin
			if (i_SPI_Clock != Clock_State) begin
				Clock_State <= i_SPI_Clock;
			end
			if (i_SPI_Data != Data_State) begin
				Data_State <= i_SPI_Data;
			end
			if (i_SPI_CS != CS_State) begin
				CS_State <= i_SPI_CS;
			end

			if (i_SPI_Clock == Clock_State && i_SPI_Data == Data_State && i_SPI_CS == CS_State) begin
				Count_Stable <= Count_Stable + 1'b1;
				if (Count_Stable == 2) begin
					CS_Stable <= i_SPI_CS;
					Clock_Stable <= i_SPI_Clock;
				end
			end
			else begin
				Count_Stable <= 1'b0;
			end
		end
	end


	always @(posedge Clock_Stable or posedge CS_Stable) begin
		if (CS_Stable) begin
			SM_ADC_In <= sm_waiting;
		end
		else begin		//  check there have been at least two counts of negative pulse before recording a valid SPI clock cycle
			case (SM_ADC_In)
				sm_waiting:
					begin
						SM_ADC_In <= sm_receiving;
						Receive_Byte <= 1'b0;
						Receive_Bit <= 1'b1;
						o_Data_Received <= 1'b0;
						r_Bytes_In[0][0] <= Data_State;
					end

				sm_receiving:
					begin
						r_Bytes_In[Receive_Byte][Receive_Bit] <= Data_State;
						Receive_Bit <= Receive_Bit + 1'b1;

						if (Receive_Bit == 15) begin								// Byte received
							Receive_Byte <= Receive_Byte + 1'b1;
							if (Receive_Byte == RECEIVEBYTES - 1) begin		// If all bytes received set state back to waiting and activate received flag
								o_Data_Received <= 1'b1;
								Receive_Byte <= 1'b0;
								SM_ADC_In <= sm_waiting;
							end
							else begin
								Receive_Bit <= 0;
							end
						end
					end
			endcase
		end
	end

endmodule