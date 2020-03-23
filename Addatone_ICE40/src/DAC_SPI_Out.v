module DAC_SPI_Out
	(
		input wire i_Clock,
		input wire i_Reset,
		input wire [23:0] i_Data,
		input wire i_Send,
		output reg o_SPI_CS,
		output wire o_SPI_Clock,
		output reg o_SPI_Data,
		output reg o_Ready
	);
	
	reg [0:23] r_Data_To_Send;
	reg [4:0] Current_Bit = 1'b0;
	reg Clock_Counter = 1'b0;

	reg [4:0] SM_DAC_Out = 4'd0;
	localparam sm_idle = 4'b0001;
	localparam sm_sending = 4'b0010;
	localparam sm_sent = 4'b0100;
	localparam sm_cs_pulse = 4'b1000;

	assign o_SPI_Clock = SM_DAC_Out == sm_idle || SM_DAC_Out == sm_cs_pulse || Current_Bit == 1'b0 ? 1'b1 : ~Clock_Counter;

	always @(posedge i_Clock) begin
		if (i_Reset) begin
			o_SPI_CS <= 1'b1;
			o_SPI_Data <= 1'b0;
			Clock_Counter <= 1'b0;
			o_Ready <= 1'b1;
			SM_DAC_Out <= sm_idle;
		end
		else begin		// only transition state on first clock counter - otherwise increment SPI clock

			Clock_Counter <= ~Clock_Counter;

			if (i_Send) begin
				o_Ready <= 1'b0;
			end
			
			if (Clock_Counter) begin

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
						end
						
					sm_sent:
						begin
							o_SPI_CS <= 1'b1;
							o_SPI_Data <= 1'b0;
							SM_DAC_Out <= sm_cs_pulse;
						end
						
					sm_cs_pulse:
						begin
							o_Ready <= 1'b1;
							SM_DAC_Out <= sm_idle;
						end
						
					default:
						SM_DAC_Out <= sm_idle;

				endcase
			end
		end
	end

endmodule
