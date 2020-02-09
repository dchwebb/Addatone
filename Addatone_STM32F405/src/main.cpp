#include "initialisation.h"

volatile uint32_t SysTickVal;

extern uint32_t SystemCoreClock;
volatile uint16_t ADC_array[ADC_BUFFER_LENGTH * 4];		// increase buffer size to allow oversampling

// Create aliases for ADC inputs
volatile uint16_t& ADC_PITCH = ADC_array[0];	// PB0 ADC12_IN8   Pin 26
volatile uint16_t& ADC_FTUNE = ADC_array[1];	// PB1 ADC12_IN9   Pin 27
volatile float pitch;
volatile float freq = 220;
volatile bool fup = 1;

extern "C" {
#include "interrupts.h"
}



int main(void)
{
	SystemInit();							// Activates floating point coprocessor and resets clock
	SystemClock_Config();					// Configure the clock and PLL
	SystemCoreClockUpdate();				// Update SystemCoreClock (system clock frequency) derived from settings of oscillators, prescalers and PLL
	InitADC();								// Configure ADC for analog controls
	InitSPI();								// SPI on PB3 (SPI3_SCK pin 55) and PB5 (SPI3_MOSI pin 57)
	InitSPITimer();

	int i = 0;


	while (1) {
		i++;
	}
}
