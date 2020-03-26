/* Wrapper for pll primitive. PLL calculation :
	f_Out = f_Clock_In x (DIVF + 1)  =  12 * 64  =  48MHz
				---------------------      -------
				 2^DIVQ x (DIVR + 1)       2^4 x 1
*/
module PLL_Primitive_48MHz (
	input i_Reset,
	input i_Clock,
	output o_PLL_Clock
);
	wire Feedback;

	PLL_B #(.DIVR("0"),
		.DIVF("63"),
		.DIVQ("4"),
		.FEEDBACK_PATH("SIMPLE"),
		.FILTER_RANGE("1"),
		.DELAY_ADJUSTMENT_MODE_FEEDBACK("FIXED"),
		.FDA_FEEDBACK("0"),
		.DELAY_ADJUSTMENT_MODE_RELATIVE("FIXED"),
		.FDA_RELATIVE("0"),
		.SHIFTREG_DIV_MODE("0"),
		.PLLOUT_SELECT_PORTA("GENCLK"),
		.PLLOUT_SELECT_PORTB("GENCLK"),
		.EXTERNAL_DIVIDE_FACTOR("NONE"),
		.ENABLE_ICEGATE_PORTA("0"),
		.ENABLE_ICEGATE_PORTB("0"),
		.FREQUENCY_PIN_REFERENCECLK("12.000000")
	) 
	u_PLL_B (.REFERENCECLK(i_Clock), 
		.RESET_N(~i_Reset), 
		.FEEDBACK(Feedback),
		.DYNAMICDELAY7(1'b0), 
		.DYNAMICDELAY6(1'b0),
		.DYNAMICDELAY5(1'b0), 
		.DYNAMICDELAY4(1'b0),
		.DYNAMICDELAY3(1'b0),
		.DYNAMICDELAY2(1'b0),
		.DYNAMICDELAY1(1'b0),
		.DYNAMICDELAY0(1'b0),
		.INTFBOUT(Feedback), 
		.BYPASS(bypass_i), 
		.LATCH(1'b0), 
		.OUTCORE(o_PLL_Clock), 
		.OUTGLOBAL(), 
		.OUTCOREB(), 
		.OUTGLOBALB(), 
		.LOCK(), 
		.SCLK(), 
		.SDI(), 
		.SDO()
	);

endmodule


