#include "initialisation.h"

volatile uint32_t SysTickVal;

extern uint32_t SystemCoreClock;
volatile uint16_t ADC_array[ADC_BUFFER_LENGTH * 4];

// Create aliases for ADC inputs
volatile uint16_t& ADC_PITCH = ADC_array[0];	// PB0 ADC12_IN8   Pin 26
volatile uint16_t& ADC_FTUNE = ADC_array[1];	// PB1 ADC12_IN9   Pin 27
volatile float pitch;
volatile float freq = 220;
volatile uint16_t harmonicScale;
volatile uint16_t dampedHarmonicScale;
volatile uint16_t startVol;
volatile uint16_t outputVal;
volatile int16_t freqScale;
volatile uint16_t combInterval;
volatile uint16_t combIntervalTemp;				// Temporary value used for hysteresis
volatile float harmScale;
volatile bool harmonicDir;
volatile bool fup = 1;

extern "C" {
#include "interrupts.h"
}

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
