// SPI Send timer
void TIM3_IRQHandler(void) {
	// create macro to enable summing of four most recent values of ADC regardless of how many ADC samples are in the buffer
	#define ADC_SUM(x) (ADC_array[x] + ADC_array[ADC_BUFFER_LENGTH + x] + ADC_array[ADC_BUFFER_LENGTH * 2 + x] + ADC_array[ADC_BUFFER_LENGTH * 3 + x])

	TIM3->SR &= ~TIM_SR_UIF;					// clear UIF flag

	// Pitch calculations - Increase 2270 to increase pitch; Reduce ABS(610) to increase spread
	pitch = (float)((ADC_SUM(0)) >> 2);
	//freq = 2270.0f * std::pow(2.0f, pitch / -610.0f);			// for cycle length matching sample rate (48k)
	freq = 2880.0f * std::pow(2.0f, pitch / -633.0f);			// for cycle length of 65k
	sendSPIData((uint16_t)freq);


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
	 * or for 512: c = 511/9 = 56.777
	 */

	/* 255 levels
	// pass the start volume - signals with more harmonics will be attenuated progressively
	harmonicScale = (uint16_t)(ADC_array[2] + ADC_array[5] + ADC_array[8] + ADC_array[11]) >> 6;		// scale 0 to 255
	dampedHarmonicScale = ((7 * dampedHarmonicScale) + harmonicScale) >> 3;
	harmScale = ((31.0f * harmScale) + (std::pow(2.0f, (float)dampedHarmonicScale / 31.875f) - 1)) / 32.0f;
	uint16_t minLevel = 140;
	startVol = minLevel + (harmScale * (255 - minLevel) / 255);
	outputVal = ((uint8_t)harmScale) | (startVol << 8);
	sendSPIData(outputVal);
	 */

	//harmonicScale = (uint16_t)(ADC_array[2] + ADC_array[5] + ADC_array[8] + ADC_array[11]) >> 5;		// scale 0 to 511
	harmonicScale = (uint16_t)(ADC_SUM(2)) >> 5;		// scale 0 to 511
	dampedHarmonicScale = ((15 * dampedHarmonicScale) + harmonicScale) >> 4;
	harmScale = ((31.0f * harmScale) + uint16_t(std::pow(2.0f, (float)dampedHarmonicScale / 56.777f) - 1)) / 32.0f;
	sendSPIData((uint16_t)harmScale);

	// Create inverted exponential curve for volume reduction
	float vol = (511.0f - (float)harmScale) / 511.0f;
	startVol = ((0.7f - 0.7f * std::pow(vol, 4.0f)) + 0.3f) * 511.0f;
	sendSPIData(startVol);

	// Send CV value for frequency scaling
	freqScale = 127 - ((ADC_SUM(3)) >> 7);		// scale to range 0-127
	sendSPIData(freqScale);

	// Send potentiometer value for Comb Filter Interval
	if (combIntervalTemp > ADC_SUM(1) + 500 || combIntervalTemp < ADC_SUM(1) - 500)
		combIntervalTemp = ADC_SUM(1);
	combInterval = combIntervalTemp >> 9;		// scale to range 0-31
	sendSPIData(combInterval);

	clearSPI();
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

