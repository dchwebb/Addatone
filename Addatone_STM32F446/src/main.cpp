#include "initialisation.h"
#include "bitstream.h"

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

extern "C" {
#include "interrupts.h"
}

void programFPGA() {
	// SPI clock should be between 1 and 25MHz with minimum clock low/high time of 20ns)

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
	//SPI2->CR1 &= ~SPI_CR1_CPOL;						// Switch the clock polarity back to idle low to drive clock pin low
	while (((SPI2->SR & SPI_SR_TXE) == 0) | ((SPI2->SR & SPI_SR_BSY) == SPI_SR_BSY) );
	GPIOB->BSRR |= GPIO_BSRR_BR_12;

	// Send the bitstream MSB first, data clocked into FPGA on rising edge
	for (int b = 0; b < bitstreamSize; ++b) {
	//for (int b = 0; b < 30; ++b) {
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
	//SPI2->CR1 |= SPI_CR1_CPOL;						// Reset the clock polarity to idle high
	SPI2->CR1 &= ~SPI_CR1_SPE;				// Disable FPGA Programming SPI as lines cross oscillator input from MCU
}

float i2sVal = 0;
float oldVal = 0;
int32_t send = 0;
uint32_t i = 0;
int8_t inc = 20;

extern uint32_t SystemCoreClock;
int main(void)
{
	SystemInit();							// Activates floating point coprocessor and resets clock
	SystemClock_Config();					// Configure the clock and PLL
	SystemCoreClockUpdate();				// Update SystemCoreClock (system clock frequency) derived from settings of oscillators, prescalers and PLL
	InitMCO2();								// Initialise output of HSE oscillator on pin PC9
	InitSysTick();

	InitFPGAProg();
	programFPGA();

	InitIO();
	InitADC();
	InitSPI();
	InitSPITimer();


	while (1)
	{
		/*
		 * 		i2sVal += inc;
		if (i2sVal > 20000 || i2sVal < -20000) {
			inc *= -1;
		}
		if (i2sVal > 20000) {
			i2sVal = -20000;
		}

		//int16_t i2sOut = (int16_t)i2sVal;
		int16_t i2sOut = (int16_t)((i2sVal + oldVal) / 2.0f);

		while ((SPI2->SR & SPI_SR_TXE) == 0);
		SPI2->DR = i2sOut;
		while ((SPI2->SR & SPI_SR_TXE) == 0);
		SPI2->DR = i2sOut;
		while ((SPI2->SR & SPI_SR_TXE) == 0);
		SPI2->DR = 0x3799;
		while ((SPI2->SR & SPI_SR_TXE) == 0);
		SPI2->DR = 0xCCDD;

		oldVal = i2sOut;
		*/
	}
}

