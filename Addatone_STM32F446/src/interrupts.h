/*void ADC1_IRQHandler(void) {

	uint16_t adcval = ADC1->DR;
}*/

/*
#define PITCH_CV       0
#define HARM1_CV       1
#define HARM2_CV       2
#define WARP_CV        3
#define HARMCNT_POT    4
#define FTUNE_POT      5
#define CTUNE_POT      6
#define HARM1_POT      7
#define HARM2_POT      8
#define WARP_POT       9
*/

// SPI Send timer
void TIM3_IRQHandler(void) {
	// create macro to enable summing of four most recent values of ADC regardless of how many ADC samples are in the buffer
	#define ADC_SUM(x) (ADC_array[x] + ADC_array[ADC_BUFFER_LENGTH + x] + ADC_array[ADC_BUFFER_LENGTH * 2 + x] + ADC_array[ADC_BUFFER_LENGTH * 3 + x])
	#define ADC_REV(x) 16384 - ADC_SUM(x)

	TIM3->SR &= ~TIM_SR_UIF;					// clear UIF flag

	//	Coarse tuning - add some hysteresis to prevent jumping
	if (coarseTune > ADC_array[CTUNE_POT] + 128 || coarseTune < ADC_array[CTUNE_POT] - 128)
		coarseTune = ADC_array[CTUNE_POT];

	int16_t octave = 0;
	if (coarseTune > 3412)
		octave = -2 * 590;
	else if (coarseTune > 2728)
		octave = -590;
	else if (coarseTune < 682)
		octave = 2 * 590;
	else if (coarseTune < 1364)
		octave = 590;

	// Pitch calculations - Increase 2270 to increase pitch; Reduce ABS(610) to increase spread
	float ftune = (8192.0f - ADC_SUM(FTUNE_POT)) / 14.0f;				// Gives around an octave of fine tune
	pitch = (float)(ADC_SUM(PITCH_CV) >> 2) + ftune + (float)octave;
	//freq = 2270.0f * std::pow(2.0f, pitch / -610.0f);			// for cycle length matching sample rate (48k)
	freq = 3200.0f * std::pow(2.0f, pitch / -590.0f);			// for cycle length of 65k


	/* Scaling logic
	 * Pass the amount of reduction applied to each successive harmonic - this will create a linear reduction scale
	 * However this causes too much of the scale to bunched around heavy attenuation of harmonics.
	 * We therefore want to scale the reduction with the same start and end points (eg 0 and 255) but with an exponential shape:
	 * Formula: y = 2^(x/c) - 1
	 * Where y is the scaled output, x is the input, c is a constant used to keep the maximum value the same
	 * To calculate c, set x = y = maximum (eg 255) and solve:
	 * x/c = log2(y + 1)
	 * x = c log2(y + 1 ) ; setting m = 255:
	 * c = m / log2(m + 1) = 255/8 = 31.875
	 * or for 512: c = 511/9 = 56.777
	 * for 2048: c = 2047/11 = 186.09
	 */

	constexpr float maxScale = 2047.0f;
	constexpr uint8_t scaleInit = std::log2(std::pow(2, 14) / (maxScale + 1));
	constexpr float scaleDivisor = maxScale / std::log2(maxScale + 1);

	harmonicScaleOdd = std::max((int32_t)(ADC_SUM(HARM1_CV) + ADC_REV(HARM1_POT)) - 16384, 0l) >> scaleInit;		// Scaled from 16384 to 0, divided by 3
	dampedHarmonicScaleOdd = ((15 * dampedHarmonicScaleOdd) + harmonicScaleOdd) >> 4;
	harmScaleOdd = ((31.0f * harmScaleOdd) + uint16_t(std::pow(2.0f, (float)dampedHarmonicScaleOdd / scaleDivisor) - 1)) / 32.0f;

	harmonicScaleEven = std::max((int32_t)(ADC_SUM(HARM2_CV) + ADC_REV(HARM2_POT)) - 16384, 0l) >> scaleInit;
	dampedHarmonicScaleEven = ((15 * dampedHarmonicScaleEven) + harmonicScaleEven) >> 4;
	harmScaleEven = ((31.0f * harmScaleEven) + uint16_t(std::pow(2.0f, (float)dampedHarmonicScaleEven / scaleDivisor) - 1)) / 32.0f;

	// Create inverted exponential curve for volume reduction
	float volOdd = (maxScale - (float)harmScaleOdd) / maxScale;
	startVolOdd = ((0.7f - 0.7f * std::pow(volOdd, 4.0f)) + 0.3f) * maxScale;

	// Create inverted exponential curve for volume reduction
	float volEven = (maxScale - (float)harmScaleEven) / maxScale;
	startVolEven = ((0.7f - 0.7f * std::pow(volEven, 4.0f)) + 0.3f) * maxScale;

	// Send CV value for frequency scaling
	freqScale = std::min((int16_t)(ADC_REV(WARP_CV) + ADC_SUM(WARP_POT)) >> 7, 127);		// scale to range 0-127

	// Send potentiometer value for number of harmonics - this uses hysteresis to avoid jumping
	if (harmCountTemp > ADC_array[HARMCNT_POT] + 20 || harmCountTemp < ADC_array[HARMCNT_POT] - 20)
		harmCountTemp = ADC_array[HARMCNT_POT];
	// Scale input with formula y=(x^2)/128 to give a flattened exponential curve (more control over fewer number of harmonics)
	harmCount = std::pow(harmCountTemp >> 5, 2) / 128;		// scale to range 0-127


	sendSPIData((uint16_t)freq);
	sendSPIData((uint16_t)harmScaleOdd);
	sendSPIData(startVolOdd);
	sendSPIData((uint16_t)harmScaleEven);
	sendSPIData(startVolEven);
	sendSPIData(freqScale);
	sendSPIData(harmCount);

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

