#include "initialisation.h"
#include "fpgaHandler.h"

volatile uint32_t SysTickVal;

extern uint32_t SystemCoreClock;
volatile uint16_t ADC_array[ADC_BUFFER_LENGTH * 4];



extern "C" {
#include "interrupts.h"
}

Config config{&fpga.configSaver};			// Construct config handler with list of configSavers

int main(void)
{
	SystemInit();							// Activates floating point coprocessor and resets clock
	InitHardware();							// Configure the clock and PLL

	fpga.ProgramBitstream();

	config.RestoreConfig();
	InitADC();
	InitSPITimer();

	while (1) {

	}
}

