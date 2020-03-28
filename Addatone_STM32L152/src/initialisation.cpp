#include "initialisation.h"

#define USE_HSE
#define PLL_M 4
#define PLL_N 168
#define PLL_P 2		//  Main PLL (PLL) division factor for main system clock can be 2 (PLL_P = 0), 4 (PLL_P = 1), 6 (PLL_P = 2), 8 (PLL_P = 3)
#define PLL_Q 0

void SystemClock_Config(void) {

	//NVIC_SetPriorityGrouping(NVIC_PRIORITYGROUP_4);
	//RCC->APB1ENR |= RCC_APB1ENR_COMPEN;			// Enable comparator
	RCC->APB2ENR |= RCC_APB2ENR_SYSCFGEN;

	RCC->APB1ENR |= RCC_APB1ENR_PWREN;			// Enable Power Control clock
	PWR->CR |= PWR_CR_VOS_0;					// Enable VOS voltage scaling - allows maximum clock speed
	PWR->CR &= ~PWR_CR_VOS_1;
	while (PWR->CSR & PWR_CSR_VOSF);			// Wait until VOS scaling is finished

	//SCB->CPACR |= ((3UL << 10*2)|(3UL << 11*2));// CPACR register: set full access privileges for coprocessors

	RCC->CR |= RCC_CR_HSEON;					// HSE ON
	while ((RCC->CR & RCC_CR_HSERDY) == 0);		// Wait till HSE is ready
	RCC->CFGR |= RCC_CFGR_PLLDIV2;				// 01: PLLVCO/2; 10: PLLVCO/3; 11: PLLVCO/4
	RCC->CFGR |= RCC_CFGR_PLLMUL4;				// 0011: PLLVCO = PLL clock entry x 8
	RCC->CFGR |= RCC_CFGR_PLLSRC_HSE;			// 0: HSI oscillator clock selected as PLL input clock; 1: HSE oscillator clock selected as PLL input clock

    RCC->CFGR |= RCC_CFGR_HPRE_DIV1;			// AHB prescaler
	RCC->CFGR |= RCC_CFGR_PPRE1_DIV1;			// APB low-speed prescaler (APB1)
	RCC->CFGR |= RCC_CFGR_PPRE2_DIV1;			// APB low-speed prescaler (APB2)

	RCC->CR |= RCC_CR_PLLON;					// Enable the main PLL
	while((RCC->CR & RCC_CR_PLLRDY) == 0);		// Wait till the main PLL is ready


	//	Turn on HSI - Needed for ADC to function
	RCC->CR |= RCC_CR_HSION;

	// Configure Flash prefetch, Instruction cache, Data cache and wait state
//	FLASH->ACR = FLASH_ACR_PRFTEN | FLASH_ACR_LATENCY;		//  | FLASH_ACR_ICEN | FLASH_ACR_DCEN

	// Select the main PLL as system clock source
	RCC->CFGR &= ~RCC_CFGR_SW;
	RCC->CFGR |= RCC_CFGR_SW_PLL;

	// Wait till the main PLL is used as system clock source
	while ((RCC->CFGR & (uint32_t)RCC_CFGR_SWS ) != RCC_CFGR_SWS_PLL);

}

void InitSimpleADC(void)
{

	// Enable ADC and GPIO clock sources
	RCC->AHBENR |= RCC_AHBENR_GPIOBEN;
	RCC->APB2ENR |= RCC_APB2ENR_ADC1EN;

	// Enable ADC - PB0: IN8;
	GPIOB->MODER |= GPIO_MODER_MODER0;				// Set PB0 to Analog mode (0b11)

	ADC1->SQR5 |= 8 << 0;							// Set IN8  1st conversion in sequence

	//	Set to 56 cycles (0b11) sampling speed (SMPR2 Left shift speed 3 x ADC_INx up to input 9; use SMPR1 from 0 for ADC_IN10+)
	// 000: 3 cycles; 001: 15 cycles; 010: 28 cycles; 011: 56 cycles; 100: 84 cycles; 101: 112 cycles; 110: 144 cycles; 111: 480 cycles
	ADC1->SMPR3 |= 0b110 << 24;						// Set speed of IN8

	ADC1->CR2 |= ADC_CR2_EOCS;						// Trigger interrupt on end of each individual conversion

	ADC1->CR1 |= ADC_CR1_EOCIE;
	NVIC_EnableIRQ(ADC1_IRQn);

	ADC1->CR2 |= ADC_CR2_ADON;						// Activate ADC
}


void InitADC(void)
{
	//	Setup Timer 2 to trigger ADC
	RCC->APB1ENR |= RCC_APB1ENR_TIM2EN;				// Enable Timer 2 clock
	TIM2->CR2 |= TIM_CR2_MMS_2;						// 100: Compare - OC1REF signal is used as trigger output (TRGO)
	TIM2->PSC = 20 - 1;								// Prescaler
	TIM2->ARR = 100 - 1;							// Auto-reload register (ie reset counter) divided by 100
	TIM2->CCR1 = 50 - 1;							// Capture and compare - ie when counter hits this number PWM high
	TIM2->CCER |= TIM_CCER_CC1E;					// Capture/Compare 1 output enable
	TIM2->CCMR1 |= TIM_CCMR1_OC1M_1 |TIM_CCMR1_OC1M_2;	// 110 PWM Mode 1
	TIM2->CR1 |= TIM_CR1_CEN;

	// Enable ADC2 and GPIO clock sources
	RCC->AHBENR |= RCC_AHBENR_GPIOAEN;
	RCC->AHBENR |= RCC_AHBENR_GPIOBEN;
	RCC->AHBENR |= RCC_AHBENR_GPIOCEN;
	RCC->APB2ENR |= RCC_APB2ENR_ADC1EN;

	// Enable ADC - Set Pins to Analog mode (0b11)
	GPIOA->MODER |= GPIO_MODER_MODER0;				// Set PA0 ADC_IN0
	GPIOA->MODER |= GPIO_MODER_MODER1;				// Set PA1 ADC_IN1
	GPIOA->MODER |= GPIO_MODER_MODER2;				// Set PA2 ADC_IN2
	GPIOA->MODER |= GPIO_MODER_MODER3;				// Set PA3 ADC_IN3
	GPIOA->MODER |= GPIO_MODER_MODER4;				// Set PA4 ADC_IN4
	GPIOA->MODER |= GPIO_MODER_MODER5;				// Set PA5 ADC_IN5
	GPIOA->MODER |= GPIO_MODER_MODER6;				// Set PA6 ADC_IN6 *** Not Working
	GPIOA->MODER |= GPIO_MODER_MODER7;				// Set PA7 ADC_IN7

	GPIOB->MODER |= GPIO_MODER_MODER0;				// Set PB0 ADC_IN8
	GPIOB->MODER |= GPIO_MODER_MODER1;				// Set PB1 ADC_IN9 *** Not working

	GPIOB->MODER |= GPIO_MODER_MODER12;				// Set PB12 ADC_IN18
	GPIOB->MODER |= GPIO_MODER_MODER13;				// Set PB13 ADC_IN19 *** Not Working
	GPIOB->MODER |= GPIO_MODER_MODER14;				// Set PB14 ADC_IN20 *** Not Working
	GPIOB->MODER |= GPIO_MODER_MODER15;				// Set PB15 ADC_IN21

	ADC1->CR1 |= ADC_CR1_SCAN;						// Activate scan mode
	ADC1->SQR1 = (ADC_BUFFER_LENGTH - 1) << 20;		// Number of conversions in sequence
	ADC1->SQR5 |= 18 << 0;							// Set IN18  1st conversion in sequence
	ADC1->SQR5 |= 19 << 5;							// Set IN19  2nd conversion in sequence
	ADC1->SQR5 |= 20 << 10;							// Set IN20  3rd conversion in sequence
	ADC1->SQR5 |= 9 << 15;							// Set IN9  4th conversion in sequence
	ADC1->SQR5 |= 8 << 20;							// Set IN8  5th conversion in sequence
//	xx ADC1->SQR5 |= 10 << 25;						// Set IN10 6th conversion in sequence
//	ADC1->SQR4 |= 12 << 0;							// Set IN12 7th conversion in sequence
//	ADC1->SQR4 |= 14 << 5;							// Set IN14 8th conversion in sequence
//	ADC1->SQR4 |= 7 << 10;							// Set IN7  9th conversion in sequence
//	ADC1->SQR4 |= 11 << 15;							// Set IN11 10th conversion in sequence

	//	Set to 56 cycles (0b11) sampling speed (SMPR2 Left shift speed 3 x ADC_INx up to input 9; use SMPR1 from 0 for ADC_IN10+)
	// 000: 3 cycles; 001: 15 cycles; 010: 28 cycles; 011: 56 cycles; 100: 84 cycles; 101: 112 cycles; 110: 144 cycles; 111: 480 cycles
	ADC1->SMPR2 |= 0b110 << 24;						// Set speed of IN18
	ADC1->SMPR2 |= 0b110 << 27;						// Set speed of IN19
	ADC1->SMPR1 |= 0b110 << 0;						// Set speed of IN20
	ADC1->SMPR3 |= 0b110 << 27;						// Set speed of IN9
	ADC1->SMPR3 |= 0b110 << 24;						// Set speed of IN8
//	ADC1->SMPR1 |= 0b110 << 0;						// Set speed of IN10
//	ADC1->SMPR1 |= 0b110 << 6;						// Set speed of IN12
//	ADC1->SMPR1 |= 0b110 << 12;						// Set speed of IN14
//	ADC1->SMPR2 |= 0b110 << 21;						// Set speed of IN7
//	ADC1->SMPR1 |= 0b110 << 3;						// Set speed of IN11

	ADC1->CR2 |= ADC_CR2_EOCS;						// Trigger interrupt on end of each individual conversion
	ADC1->CR2 |= ADC_CR2_EXTEN_0;					// ADC hardware trigger 00: Trigger detection disabled; 01: Trigger detection on the rising edge; 10: Trigger detection on the falling edge; 11: Trigger detection on both the rising and falling edges
	ADC1->CR2 |= ADC_CR2_EXTSEL_1 | ADC_CR2_EXTSEL_2;	// ADC External trigger: 0110 = TIM2_TRGO event

	// Enable DMA - DMA1, Channel 1  = ADC1 (Manual p255)
	ADC1->CR2 |= ADC_CR2_DMA;						// Enable DMA Mode on ADC
	ADC1->CR2 |= ADC_CR2_DDS;						// DMA requests are issued as long as data are converted and DMA=1
	RCC->AHBENR |= RCC_AHBENR_DMA1EN;

	DMA1_Channel1->CCR &= ~DMA_CCR_DIR;				// 00 = Peripheral-to-memory
	DMA1_Channel1->CCR |= DMA_CCR_PL_1;				// Priority: 00 = low; 01 = Medium; 10 = High; 11 = Very High
	DMA1_Channel1->CCR |= DMA_CCR_PSIZE_0;			// Peripheral size: 8 bit; 01 = 16 bit; 10 = 32 bit
	DMA1_Channel1->CCR |= DMA_CCR_MSIZE_0;			// Memory size: 8 bit; 01 = 16 bit; 10 = 32 bit
	DMA1_Channel1->CCR &= ~DMA_CCR_PINC;			// Peripheral not in increment mode
	DMA1_Channel1->CCR |= DMA_CCR_MINC;				// Memory in increment mode
	DMA1_Channel1->CCR |= DMA_CCR_CIRC;				// circular mode to keep refilling buffer
	DMA1_Channel1->CCR &= ~DMA_CCR_DIR;				// data transfer direction: 00: peripheral-to-memory; 01: memory-to-peripheral; 10: memory-to-memory

	DMA1_Channel1->CNDTR |= ADC_BUFFER_LENGTH * 4;	// Number of data items to transfer (ie size of ADC buffer)
	DMA1_Channel1->CPAR = (uint32_t)(&(ADC1->DR));	// Configure the peripheral data register address
	DMA1_Channel1->CMAR = (uint32_t)(ADC_array);	// Configure the memory address (note that M1AR is used for double-buffer mode)
	//DMA1_Channel1->CCR |= DMA_CCR_CHSEL_0;		// channel select to 1 for ADC2

	DMA1_Channel1->CCR |= DMA_CCR_EN;				// Enable DMA2
	ADC1->CR2 |= ADC_CR2_ADON;						// Activate ADC
}

void InitIO()
{
	RCC->AHBENR |= RCC_AHBENR_GPIOAEN;			// reset and clock control - advanced high performance bus - GPIO port A
	RCC->AHBENR |= RCC_AHBENR_GPIOBEN;			// reset and clock control - advanced high performance bus - GPIO port B
	RCC->AHBENR |= RCC_AHBENR_GPIOCEN;			// reset and clock control - advanced high performance bus - GPIO port C
}

void InitSysTick()
{
	// Register macros found in core_cm4.h
	SysTick->CTRL = 0;									// Disable SysTick
	SysTick->LOAD = 0xFFFF - 1;							// Set reload register to maximum 2^24 - each tick is around 400us

	// Set priority of Systick interrupt to least urgency (ie largest priority value)
	NVIC_SetPriority (SysTick_IRQn, (1 << __NVIC_PRIO_BITS) - 1);

	SysTick->VAL = 0;									// Reset the SysTick counter value

	SysTick->CTRL |= SysTick_CTRL_CLKSOURCE_Msk;		// Select processor clock: 1 = processor clock; 0 = external clock
	SysTick->CTRL |= SysTick_CTRL_TICKINT_Msk;			// Enable SysTick interrupt
	SysTick->CTRL |= SysTick_CTRL_ENABLE_Msk;			// Enable SysTick
}

/*

//	Setup Timer 9 to count clock cycles for coverage profiling
void InitCoverageTimer() {
	RCC->APB2ENR |= RCC_APB2ENR_TIM9EN;				// Enable Timer
	TIM9->PSC = 100;
	TIM9->ARR = 65535;

	TIM9->DIER |= TIM_DIER_UIE;						// DMA/interrupt enable register
	NVIC_EnableIRQ(TIM1_BRK_TIM9_IRQn);
	NVIC_SetPriority(TIM1_BRK_TIM9_IRQn, 2);		// Lower is higher priority

}

*/

void InitSPI()
{
	//	Enable GPIO and SPI clocks
	RCC->AHBENR |= RCC_AHBENR_GPIOAEN;			// reset and clock control - advanced high performance bus - GPIO port A
	RCC->AHBENR |= RCC_AHBENR_GPIOBEN;			// reset and clock control - advanced high performance bus - GPIO port B
	RCC->APB2ENR |= RCC_APB2ENR_SPI1EN;

	// PB5 (57): SPI_MOSI [alternate function AF5]
	GPIOB->MODER |= GPIO_MODER_MODER5_1;			// 00: Input (reset state)	01: General purpose output mode	10: Alternate function mode	11: Analog mode
	GPIOB->OSPEEDR |= GPIO_OSPEEDER_OSPEEDR5;		// V High  - 00: Low speed; 01: Medium speed; 10: High speed; 11: Very high speed
	GPIOB->AFR[0] |= 0b0101 << 20;					// 0b0110 = Alternate Function 5 (SPI1); 20 is position of Pin 5

	// PB3 (55) SPI_SCK [alternate function AF5]
	GPIOB->MODER &= ~GPIO_MODER_MODER3;				// Reset value of PB3 is 0b10
	GPIOB->MODER |= GPIO_MODER_MODER3_1;			// 00: Input (reset state)	01: General purpose output mode	10: Alternate function mode	11: Analog mode
	GPIOB->OSPEEDR |= GPIO_OSPEEDER_OSPEEDR3;		// V High  - 00: Low speed; 01: Medium speed; 10: High speed; 11: Very high speed
	GPIOB->AFR[0] |= 0b0101 << 12;					// 0b0110 = Alternate Function 5 (SPI1); 12 is position of Pin 3

	// PA15 (50) Software NSS
	GPIOA->MODER |= GPIO_MODER_MODER15_0;			// 00: Input (reset state)	01: General purpose output mode	10: Alternate function mode	11: Analog mode
	GPIOA->MODER &= ~GPIO_MODER_MODER15_1;
	GPIOA->BSRR |= GPIO_BSRR_BS_15;

	// Configure SPI
	SPI1->CR1 |= SPI_CR1_DFF;						// Use 16 bit data frame
	SPI1->CR1 |= SPI_CR1_SSM;						// Software slave management: When SSM bit is set, NSS pin input is replaced with the value from the SSI bit
	SPI1->CR1 |= SPI_CR1_SSI;						// Internal slave select
	SPI1->CR1 |= SPI_CR1_BR_2;						// Baud rate control prescaler: 0b001: fPCLK/4; 0b100: fPCLK/32
	SPI1->CR1 |= SPI_CR1_MSTR;						// Master selection

	SPI1->CR1 |= SPI_CR1_SPE;						// Enable SPI
}



void sendI2SData(uint32_t data) {
	//while (((SPI1->SR & SPI_SR_TXE) == 0) | ((SPI1->SR & SPI_SR_BSY) == SPI_SR_BSY) );
	while ((SPI1->SR & SPI_SR_TXE) == 0);
	SPI1->DR = 0x5533;
	while ((SPI1->SR & SPI_SR_TXE) == 0);
	SPI1->DR = 0xAABB;
	while ((SPI1->SR & SPI_SR_TXE) == 0);
	SPI1->DR = 0x5533;
	while ((SPI1->SR & SPI_SR_TXE) == 0);
	SPI1->DR = 0xAABB;

}


void sendSPIData(uint16_t data) {
	while (((SPI1->SR & SPI_SR_TXE) == 0) | ((SPI1->SR & SPI_SR_BSY) == SPI_SR_BSY) );
	GPIOA->BSRR |= GPIO_BSRR_BR_15;
	SPI1->DR = data;		// Send cmd data [X X C C C A A A]
}

void clearSPI() {
	while (((SPI1->SR & SPI_SR_TXE) == 0) | ((SPI1->SR & SPI_SR_BSY) == SPI_SR_BSY) );
	GPIOA->BSRR |= GPIO_BSRR_BS_15;
}


//	Setup Timer 3 on an interrupt to trigger SPI data send
void InitSPITimer() {
	RCC->APB1ENR |= RCC_APB1ENR_TIM3EN;				// Enable Timer 3
	TIM3->PSC = 50;									// Set prescaler
	TIM3->ARR = 400; 								// Set auto reload register

	TIM3->DIER |= TIM_DIER_UIE;						// DMA/interrupt enable register
	NVIC_EnableIRQ(TIM3_IRQn);
	NVIC_SetPriority(TIM3_IRQn, 0);					// Lower is higher priority

	TIM3->CR1 |= TIM_CR1_CEN;
	TIM3->EGR |= TIM_EGR_UG;						//  Re-initializes counter and generates update of registers
}






