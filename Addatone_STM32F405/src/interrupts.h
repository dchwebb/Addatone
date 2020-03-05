// SPI Send timer
void TIM3_IRQHandler(void) {

	TIM3->SR &= ~TIM_SR_UIF;					// clear UIF flag

	// Pitch calculations
	//freq1 = 2270.0f * std::pow(2.0f, (float)Pitch / -610.0f);	// Increase 2270 to increase pitch; Reduce ABS(610) to increase spread

	pitch = (float)((ADC_array[0] + ADC_array[3] + ADC_array[6] + ADC_array[9]) >> 2);


	//freq = 2270.0f * std::pow(2.0f, pitch / -610.0f);			// for cycle length matching sample rate (48k)
	freq = 2880.0f * std::pow(2.0f, pitch / -633.0f);			// for cycle length of 65k

	//freq = 150;
	sendSPIData((uint16_t)freq);

	// Send fine tune data as sum of four values (4 * 4096 = 163844) left shifted to create 16 bit value (16384 << 2 = 65k)
	//harmonicScale = (uint16_t)(ADC_array[1] + ADC_array[3] + ADC_array[5] + ADC_array[7]) << 2;

/*
	if (harmonicScale < 30000) {
		harmonicDir = true;
	}
	else if (harmonicScale > 60000) {
		harmonicDir = false;
	}
	harmonicScale += harmonicDir ? 1 : -1;
*/

	//Crazy scaling formula: =2^(6*harmonicScale/65536-6)

	//harmonicScale = 65000;
	//harmScale = std::pow(2.0f, (6.0f * (float)harmonicScale / 65536.0f - 6.0f)) * (float)harmonicScale;



	//harmonicScale = (uint16_t)(ADC_array[1] + ADC_array[4] + ADC_array[7] + ADC_array[10]) >> 6;		// scale 0 to 255
	harmonicScale = (uint16_t)(ADC_array[2] + ADC_array[5] + ADC_array[8] + ADC_array[11]) >> 6;		// scale 0 to 255


	/* Scaling logic
	 * Pass the amount of reduction applied to each successive harmonic - this will create a linear reduction scale
	 * However this causes too much of the scale to bunched around heavy attenuation of harmonics.
	 * We therefore want to scale the reduction with the same start and end points (eg 0 and 255) but with an exponential shape:
	 * Formula: y = 2^(x/c) - 1
	 * Where y is the scaled output, x is the input, c is a constant used to keep the maximum value the same
	 * To calculate c, set x = y = maximum (eg 255) and solve:
	 * x/c = log2(y + 1)
	 * x = c log2(y + 1 ) ; setting n = 255:
	 * c = n / log2(n + 1) = 255/8 = 31.875
	 */
	harmScale = std::pow(2.0f, (float)harmonicScale / 31.875f) - 1;

	// pass the start volume - signals with more harmonics will be attenuated progressively
	uint16_t minLevel = 170;

	startVol = minLevel + (harmScale * (255 - minLevel) / 255);

	outputVal = ((uint8_t)harmScale) | (startVol << 8);
	sendSPIData(outputVal);

	clearSPI();

	//sendI2SData((uint32_t)0x5533AABB);
}

void SysTick_Handler(void) {
	SysTickVal++;
}

void NMI_Handler(void) {}

void HardFault_Handler(void) {
	while (1) {}
}

void MemManage_Handler(void) {
	while (1) {}
}

void BusFault_Handler(void) {
	while (1) {}
}

void UsageFault_Handler(void) {
	while (1) {}
}

void SVC_Handler(void) {}

void DebugMon_Handler(void) {}

void PendSV_Handler(void) {}

