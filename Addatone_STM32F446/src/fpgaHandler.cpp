#include "fpgaHandler.h"
#include "bitstream.h"

void fpgaHandler::SendControls()
{
	// create macro to enable summing of four most recent values of ADC regardless of how many ADC samples are in the buffer
	#define ADC_SUM(x) (ADC_array[x] + ADC_array[ADC_BUFFER_LENGTH + x] + ADC_array[ADC_BUFFER_LENGTH * 2 + x] + ADC_array[ADC_BUFFER_LENGTH * 3 + x])
	#define ADC_REV(x) 16384 - ADC_SUM(x)

	TIM3->SR &= ~TIM_SR_UIF;					// clear UIF flag

	//	Coarse tuning - add some hysteresis to prevent jumping
	if (coarseTune > ADC_array[ADC_CTune] + 128 || coarseTune < ADC_array[ADC_CTune] - 128) {
		coarseTune = ADC_array[ADC_CTune];
	}


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
	float ftune = (8192.0f - ADC_SUM(ADC_FTune)) / 14.0f;				// Gives around an octave of fine tune
	float pitch = static_cast<float>(ADC_SUM(ADC_Pitch) >> 2) + ftune + static_cast<float>(octave);
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

	uint16_t harmonicScaleOdd = std::max((int32_t)(ADC_SUM(ADC_Harm1CV) + ADC_REV(ADC_Harm1Pot)) - 16384, 0l) >> scaleInit;		// Scaled from 16384 to 0, divided by 3
	dampedHarmonicScaleOdd = ((15 * dampedHarmonicScaleOdd) + harmonicScaleOdd) >> 4;
	harmScaleOdd = ((31.0f * harmScaleOdd) + uint16_t(std::pow(2.0f, static_cast<float>(dampedHarmonicScaleOdd) / scaleDivisor) - 1)) / 32.0f;

	uint16_t harmonicScaleEven = std::max((int32_t)(ADC_SUM(ADC_Harm2CV) + ADC_REV(ADC_Harm2Pot)) - 16384, 0l) >> scaleInit;
	dampedHarmonicScaleEven = ((15 * dampedHarmonicScaleEven) + harmonicScaleEven) >> 4;
	harmScaleEven = ((31.0f * harmScaleEven) + uint16_t(std::pow(2.0f, static_cast<float>(dampedHarmonicScaleEven) / scaleDivisor) - 1)) / 32.0f;

	// Create inverted exponential curve for volume reduction
	float volOdd = (maxScale - static_cast<float>(harmScaleOdd)) / maxScale;
	startVolOdd = ((0.7f - 0.7f * std::pow(volOdd, 4.0f)) + 0.3f) * maxScale;

	// Create inverted exponential curve for volume reduction
	float volEven = (maxScale - static_cast<float>(harmScaleEven)) / maxScale;
	startVolEven = ((0.7f - 0.7f * std::pow(volEven, 4.0f)) + 0.3f) * maxScale;

	// Send CV value for frequency scaling
	freqScale = std::min((int16_t)(ADC_REV(ADC_WarpCV) + ADC_SUM(ADC_WarpPot)) >> 7, 127);		// scale to range 0-127

	// Send potentiometer value for number of harmonics - this uses hysteresis to avoid jumping
	if (harmCountTemp > ADC_array[ADC_HarmCntPot] + 20 || harmCountTemp < ADC_array[ADC_HarmCntPot] - 20) {
		harmCountTemp = ADC_array[ADC_HarmCntPot];
	}
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


void fpgaHandler::ProgramBitstream()
{
	// SPI clock should be between 1 and 25MHz with minimum clock low/high time of 20ns - currently set to around 9MHz

	// Pull reset low (PC7)
	GPIOC->BSRR |= GPIO_BSRR_BR_7;

	// Drive SPI_SS low (PB12)
	GPIOB->BSRR |= GPIO_BSRR_BR_12;

	// Hold the CRESET_B pin Low for at least 200 ns
	// Clock of 144MHz gives tick of 6.94ns so wait 400/6.94 = 57 ticks (measured at 7500ns)
	for (int i = 0; i < 60; ++i);
	GPIOC->BSRR |= GPIO_BSRR_BS_7;

	// After driving CRESET_B High the AP must wait a minimum of 1200 µs, to let the FPGA to clear its internal configuration memory
	// SysTick is set to around 400us so allow four for safety (measured at 1453us)
	int tempTime = SysTickVal;
	while (SysTickVal - tempTime < 4);

	// Drive SPI_SS high, wait 8 clock cycles then back to Low
	GPIOB->BSRR |= GPIO_BSRR_BS_12;
	SPI2->DR = 0;
	while (((SPI2->SR & SPI_SR_TXE) == 0) | ((SPI2->SR & SPI_SR_BSY) == SPI_SR_BSY) );
	GPIOB->BSRR |= GPIO_BSRR_BR_12;

	// Send the bitstream MSB first, data clocked into FPGA on rising edge
	for (int b = 0; b < bitstreamSize; ++b) {
		while (((SPI2->SR & SPI_SR_TXE) == 0) | ((SPI2->SR & SPI_SR_BSY) == SPI_SR_BSY) );
		SPI2->DR = bitstream[b];
	}

	// Drive SPI_SS High, wait 100 SPI_SCK to allow CDONE to go high.
	while (((SPI2->SR & SPI_SR_TXE) == 0) | ((SPI2->SR & SPI_SR_BSY) == SPI_SR_BSY) );
	GPIOB->BSRR |= GPIO_BSRR_BS_12;
	for (int b = 0; b < 13; ++b) {
		while (((SPI2->SR & SPI_SR_TXE) == 0) | ((SPI2->SR & SPI_SR_BSY) == SPI_SR_BSY) );
		SPI2->DR = 0;
	}

	/*
		After sending the entire image, the iCE40 FPGA releases the CDONE output allowing it to float High via the external
		pull-up resistor to AP_VCC. If the CDONE pin remains Low, then an error occurred during configuration and the AP
		should handle the error accordingly for the application.

		After the CDONE output pin goes High, send at least 49 additional dummy bits, effectively 49 additional SPI_SCK clock
		cycles measured from rising-edge to rising-edge.
	 */
	for (int b = 0; b < 7; ++b) {
		while (((SPI2->SR & SPI_SR_TXE) == 0) | ((SPI2->SR & SPI_SR_BSY) == SPI_SR_BSY) );
		SPI2->DR = 0;
	}

	SPI2->CR1 &= ~SPI_CR1_SPE;				// Disable FPGA Programming SPI as lines cross oscillator input from MCU
}
