module top 
	(
		input wire i_Mix,
		input wire i_RingMod,
		input wire i_ADC_Data,
		input wire i_ADC_Clk,
		input wire i_ADC_CS,
		output wire o_Test1,
		output wire o_Test2,
		output wire o_DAC_BClk,
		output wire o_DAC_Data,
		output wire o_DAC_LRClk
	);
	assign o_Test1 = i_ADC_Data;
	assign o_Test2 = i_ADC_Clk;
	assign o_DAC_BClk = i_RingMod;
	assign o_DAC_Data = i_Mix;
	assign o_DAC_LRClk = ~i_Mix;
endmodule