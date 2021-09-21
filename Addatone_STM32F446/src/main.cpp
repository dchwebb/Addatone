#include "initialisation.h"
#include "fpgaHandler.h"

volatile uint32_t SysTickVal;

extern uint32_t SystemCoreClock;
volatile uint16_t ADC_array[ADC_BUFFER_LENGTH * 4];

fpgaHandler fpga;

extern "C" {
#include "interrupts.h"
}

int main(void)
{
	SystemInit();							// Activates floating point coprocessor and resets clock
	SystemClock_Config();					// Configure the clock and PLL
	SystemCoreClockUpdate();				// Update SystemCoreClock (system clock frequency) derived from settings of oscillators, prescalers and PLL
	InitMCO2();								// Initialise output of HSE oscillator on pin PC9
	InitSysTick();							// Initialise SysTick used in fpga bitstream programmer
	InitFPGAProg();							// Initialise SPI peripheral used to program bitstream into FPGA

	fpga.ProgramBitstream();

	InitIO();
	InitADC();
	InitSPI();
	InitSPITimer();

	while (1) {

	}
}

