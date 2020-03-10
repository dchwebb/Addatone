#include "initialisation.h"

volatile uint32_t SysTickVal;

extern uint32_t SystemCoreClock;
volatile uint16_t ADC_array[ADC_BUFFER_LENGTH * 4];		// increase buffer size to allow oversampling

// Create aliases for ADC inputs
volatile uint16_t& ADC_PITCH = ADC_array[0];	// PB0 ADC12_IN8   Pin 26
volatile uint16_t& ADC_FTUNE = ADC_array[1];	// PB1 ADC12_IN9   Pin 27
volatile float pitch;
volatile float freq = 220;
volatile uint16_t harmonicScale;
volatile uint16_t dampedHarmonicScale;
volatile uint16_t startVol;
volatile uint16_t outputVal;
volatile uint16_t freqScale;
volatile float harmScale;
volatile bool harmonicDir;
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
//	InitI2S();								// Configure I2S for PCM5100 DAC
	InitSPI();								// SPI on PB3 (SPI3_SCK pin 55) and PB5 (SPI3_MOSI pin 57)
	InitSPITimer();

	uint32_t i = 0;


	while (1) {
		i++;
		/*uint16_t s = (uint16_t)(i >> 3);
		while ((SPI2->SR & SPI_SR_TXE) == 0);
		SPI2->DR = 0x8C00;
		while ((SPI2->SR & SPI_SR_TXE) == 0);
		SPI2->DR = 0xAABB;
		while ((SPI2->SR & SPI_SR_TXE) == 0);
		SPI2->DR = 0x3799;
		while ((SPI2->SR & SPI_SR_TXE) == 0);
		SPI2->DR = 0xCCDD;
		*/
	}
}
