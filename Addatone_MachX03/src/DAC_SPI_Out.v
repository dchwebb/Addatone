module DAC_SPI_Out
	#(parameter CLOCK_COUNT = 4'd10)			// number of internal clock events between each SPI clock transition
	(
		input wire i_Clock,
		input wire i_Reset,
		input wire [23:0] i_Data,
		input wire i_Send,
		output reg o_SPI_CS,
		output reg o_SPI_Clock,
		output reg o_SPI_Data,
		output reg o_Ready
	);
	
	reg [0:23] r_Data_To_Send;
	reg [4:0] Current_Bit;
	reg [7:0] Clock_Counter;

	reg [1:0] SM_DAC_Out;
	localparam sm_idle = 2'd0;
	localparam sm_sending = 2'd1;
	localparam sm_sent = 2'd2;
	localparam sm_cs_pulse = 2'd3;

	always @(posedge i_Clock) begin
		if (i_Reset) begin
			o_SPI_CS <= 1'b1;
			o_SPI_Data <= 1'b0;
			o_SPI_Clock <= 1'b1;
			Clock_Counter <= 1'b0;
			o_Ready <= 1'b1;
			SM_DAC_Out <= sm_idle;

		end
		else if (Clock_Counter == 0) begin		// only transition state on first clock counter - otherwise increment SPI clock
			if (SM_DAC_Out != sm_idle) begin
				Clock_Counter <= 1'b1;
			end
			
			if (i_Send)
				o_Ready <= 1'b0;

			case (SM_DAC_Out)
				sm_idle:
					begin
						o_Ready <= 1'b1;
						if (i_Send) begin
							o_Ready <= 1'b0;
							o_SPI_CS <= 1'b0;
							r_Data_To_Send <= i_Data;
							Current_Bit <= 1'b0;
							SM_DAC_Out <= sm_sending;
						end
					end
					
				sm_sending:
					begin
						if (Current_Bit == 23)
							SM_DAC_Out <= sm_sent;
						o_SPI_Data <= r_Data_To_Send[Current_Bit];
						Current_Bit <= Current_Bit + 1'b1;
						o_SPI_Clock <= 1'b1;
					end
					
				sm_sent:
					begin
						o_SPI_CS <= 1'b1;
						o_SPI_Data <= 1'b0;
						o_SPI_Clock <= 1'b1;
						SM_DAC_Out <= sm_cs_pulse;
					end
					
				sm_cs_pulse:
					begin
						o_Ready <= 1'b1;
						Clock_Counter <= 1'b0;
						SM_DAC_Out <= sm_idle;
					end

			endcase
		end
		else begin												// transition SPI clock
			if (Clock_Counter == (2 * CLOCK_COUNT) - 1) begin
				Clock_Counter <= 0;
			end
			else begin
				if (Clock_Counter == CLOCK_COUNT && SM_DAC_Out != sm_cs_pulse && SM_DAC_Out != sm_idle) begin
					o_SPI_Clock <= 0;
				end
				Clock_Counter <= Clock_Counter + 1'b1;
			end
		end
	end

endmodule
