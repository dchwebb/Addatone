#include "initialisation.h"

volatile uint32_t SysTickVal;

extern uint32_t SystemCoreClock;
volatile uint16_t ADC_array[ADC_BUFFER_LENGTH * 4];

// Create aliases for ADC inputs
volatile uint16_t& ADC_PITCH = ADC_array[0];	// PB0 ADC12_IN8   Pin 26
volatile uint16_t& ADC_FTUNE = ADC_array[1];	// PB1 ADC12_IN9   Pin 27
volatile float pitch;
volatile float freq = 220;

volatile uint16_t harmonicScaleOdd;
volatile uint16_t dampedHarmonicScaleOdd;
volatile uint16_t startVolOdd;
volatile float harmScaleOdd;

volatile uint16_t harmonicScaleEven;
volatile uint16_t dampedHarmonicScaleEven;
volatile uint16_t startVolEven;
volatile float harmScaleEven;

volatile int16_t freqScale;
volatile uint16_t harmCount;
volatile uint16_t harmCountTemp;				// Temporary value used for hysteresis

//volatile bool harmonicDir;
volatile bool fup = 1;

extern "C" {
#include "interrupts.h"
}

/*
#define LUTSIZE 1024
float PitchLUT[LUTSIZE];

void CreateLUTs(void)
{
	// Generate pitch lookup table
	for (int p = 0; p < LUTSIZE; p++){
		PitchLUT[p] = 3750.0f * std::pow(2.0f, pitch / -590.0f);			// for cycle length of 65k
	}
}
*/


int main(void)
{
	SystemInit();
	SystemClock_Config();			// NB currently highest clock speed seems to be 16MHz - higher and crashes occur
	SystemCoreClockUpdate();
	InitIO();
	InitADC();
	InitSPI();
	InitSPITimer();

	int i = 0;

	while (1) {


		i++;
	}
	return 0;
}
