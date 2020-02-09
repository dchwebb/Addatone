#include "initialisation.h"

#define USE_HSE
#define PLL_M 4
#define PLL_N 168
#define PLL_P 2		//  Main PLL (PLL) division factor for main system clock can be 2 (PLL_P = 0), 4 (PLL_P = 1), 6 (PLL_P = 2), 8 (PLL_P = 3)
#define PLL_Q 0

void SystemClock_Config(void) {

	RCC->APB1ENR |= RCC_APB1ENR_PWREN;			// Enable Power Control clock
	PWR->CR |= PWR_CR_VOS_0;					// Enable VOS voltage scaling - allows maximum clock speed

	SCB->CPACR |= ((3UL << 10*2)|(3UL << 11*2));// CPACR register: set full access privileges for coprocessors

#ifdef USE_HSE
	RCC->CR |= RCC_CR_HSEON;					// HSE ON
	while ((RCC->CR & RCC_CR_HSERDY) == 0);		// Wait till HSE is ready
	RCC->PLLCFGR = PLL_M | (PLL_N << 6) | (((PLL_P >> 1) -1) << 16) | (RCC_PLLCFGR_PLLSRC_HSE) | (PLL_Q << 24);
#endif

#ifdef USE_HSI
	RCC->CR |= RCC_CR_HSION;					// HSI ON
	while((RCC->CR & RCC_CR_HSIRDY) == 0);		// Wait till HSI is ready
    RCC->PLLCFGR = PLL_M | (PLL_N << 6) | (((PLL_P >> 1) -1) << 16) | (RCC_PLLCFGR_PLLSRC_HSI) | (PLL_Q << 24);
#endif

    RCC->CFGR |= RCC_CFGR_HPRE_DIV1;			// HCLK = SYSCLK / 1
	RCC->CFGR |= RCC_CFGR_PPRE2_DIV4;			// PCLK2 = HCLK / 2 (APB2)
	RCC->CFGR |= RCC_CFGR_PPRE1_DIV4;			// PCLK1 = HCLK / 4 (APB1)
	RCC->CR |= RCC_CR_PLLON;					// Enable the main PLL
	while((RCC->CR & RCC_CR_PLLRDY) == 0);		// Wait till the main PLL is ready

	// Configure Flash prefetch, Instruction cache, Data cache and wait state
	FLASH->ACR = FLASH_ACR_PRFTEN | FLASH_ACR_ICEN | FLASH_ACR_DCEN | FLASH_ACR_LATENCY_5WS;

	// Select the main PLL as system clock source
	RCC->CFGR &= ~RCC_CFGR_SW;
	RCC->CFGR |= RCC_CFGR_SW_PLL;

	// Wait till the main PLL is used as system clock source
	while ((RCC->CFGR & (uint32_t)RCC_CFGR_SWS ) != RCC_CFGR_SWS_PLL);

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
	RCC->AHB1ENR |= RCC_AHB1ENR_GPIOAEN;
	RCC->AHB1ENR |= RCC_AHB1ENR_GPIOBEN;
	RCC->AHB1ENR |= RCC_AHB1ENR_GPIOCEN;
	RCC->APB2ENR |= RCC_APB2ENR_ADC2EN;

	// Enable ADC - PB0: IN8; PB1: IN9; PA1: IN1; PA2: IN2; PA3: IN3; PC0: IN10, PC2: IN12, PC4: IN14; PA7: IN7, PC1: IN11
	GPIOB->MODER |= GPIO_MODER_MODER0;				// Set PB0 to Analog mode (0b11)
	GPIOB->MODER |= GPIO_MODER_MODER1;				// Set PB1 to Analog mode (0b11)
//	GPIOA->MODER |= GPIO_MODER_MODER1;				// Set PA1 to Analog mode (0b11)
//	GPIOA->MODER |= GPIO_MODER_MODER2;				// Set PA2 to Analog mode (0b11)
//	GPIOA->MODER |= GPIO_MODER_MODER3;				// Set PA3 to Analog mode (0b11)
//	GPIOC->MODER |= GPIO_MODER_MODER0;				// Set PC0 to Analog mode (0b11)
//	GPIOC->MODER |= GPIO_MODER_MODER2;				// Set PC2 to Analog mode (0b11)
//	GPIOC->MODER |= GPIO_MODER_MODER4;				// Set PC4 to Analog mode (0b11)
//	GPIOA->MODER |= GPIO_MODER_MODER7;				// Set PA7 to Analog mode (0b11)
//	GPIOC->MODER |= GPIO_MODER_MODER1;				// Set PA7 to Analog mode (0b11)

	ADC2->CR1 |= ADC_CR1_SCAN;						// Activate scan mode
	ADC2->SQR1 = (ADC_BUFFER_LENGTH - 1) << 20;		// Number of conversions in sequence
	ADC2->SQR3 |= 8 << 0;							// Set IN8  1st conversion in sequence
	ADC2->SQR3 |= 9 << 5;							// Set IN9  2nd conversion in sequence
//	ADC2->SQR3 |= 1 << 10;							// Set IN1  3rd conversion in sequence
//	ADC2->SQR3 |= 2 << 15;							// Set IN2  4th conversion in sequence
//	ADC2->SQR3 |= 3 << 20;							// Set IN3  5th conversion in sequence
//	ADC2->SQR3 |= 10 << 25;							// Set IN10 6th conversion in sequence
//	ADC2->SQR2 |= 12 << 0;							// Set IN12 7th conversion in sequence
//	ADC2->SQR2 |= 14 << 5;							// Set IN14 8th conversion in sequence
//	ADC2->SQR2 |= 7 << 10;							// Set IN7  9th conversion in sequence
//	ADC2->SQR2 |= 11 << 15;							// Set IN11 10th conversion in sequence

	//	Set to 56 cycles (0b11) sampling speed (SMPR2 Left shift speed 3 x ADC_INx up to input 9; use SMPR1 from 0 for ADC_IN10+)
	// 000: 3 cycles; 001: 15 cycles; 010: 28 cycles; 011: 56 cycles; 100: 84 cycles; 101: 112 cycles; 110: 144 cycles; 111: 480 cycles
	ADC2->SMPR2 |= 0b110 << 24;						// Set speed of IN8
	ADC2->SMPR2 |= 0b110 << 27;						// Set speed of IN9
//	ADC2->SMPR2 |= 0b110 << 3;						// Set speed of IN1
//	ADC2->SMPR2 |= 0b110 << 6;						// Set speed of IN2
//	ADC2->SMPR2 |= 0b110 << 9;						// Set speed of IN3
//	ADC2->SMPR1 |= 0b110 << 0;						// Set speed of IN10
//	ADC2->SMPR1 |= 0b110 << 6;						// Set speed of IN12
//	ADC2->SMPR1 |= 0b110 << 12;						// Set speed of IN14
//	ADC2->SMPR2 |= 0b110 << 21;						// Set speed of IN7
//	ADC2->SMPR1 |= 0b110 << 3;						// Set speed of IN11

	ADC2->CR2 |= ADC_CR2_EOCS;						// Trigger interrupt on end of each individual conversion
	ADC2->CR2 |= ADC_CR2_EXTEN_0;					// ADC hardware trigger 00: Trigger detection disabled; 01: Trigger detection on the rising edge; 10: Trigger detection on the falling edge; 11: Trigger detection on both the rising and falling edges
	ADC2->CR2 |= ADC_CR2_EXTSEL_1 | ADC_CR2_EXTSEL_2;	// ADC External trigger: 0110 = TIM2_TRGO event

	// Enable DMA - DMA2, Channel 1, Stream 2  = ADC2 (Manual p207)
	ADC2->CR2 |= ADC_CR2_DMA;						// Enable DMA Mode on ADC2
	ADC2->CR2 |= ADC_CR2_DDS;						// DMA requests are issued as long as data are converted and DMA=1
	RCC->AHB1ENR |= RCC_AHB1ENR_DMA2EN;

	DMA2_Stream2->CR &= ~DMA_SxCR_DIR;				// 00 = Peripheral-to-memory
	DMA2_Stream2->CR |= DMA_SxCR_PL_1;				// Priority: 00 = low; 01 = Medium; 10 = High; 11 = Very High
	DMA2_Stream2->CR |= DMA_SxCR_PSIZE_0;			// Peripheral size: 8 bit; 01 = 16 bit; 10 = 32 bit
	DMA2_Stream2->CR |= DMA_SxCR_MSIZE_0;			// Memory size: 8 bit; 01 = 16 bit; 10 = 32 bit
	DMA2_Stream2->CR &= ~DMA_SxCR_PINC;				// Peripheral not in increment mode
	DMA2_Stream2->CR |= DMA_SxCR_MINC;				// Memory in increment mode
	DMA2_Stream2->CR |= DMA_SxCR_CIRC;				// circular mode to keep refilling buffer
	DMA2_Stream2->CR &= ~DMA_SxCR_DIR;				// data transfer direction: 00: peripheral-to-memory; 01: memory-to-peripheral; 10: memory-to-memory

	DMA2_Stream2->NDTR |= ADC_BUFFER_LENGTH * 4;		// Number of data items to transfer (ie size of ADC buffer)
	DMA2_Stream2->PAR = (uint32_t)(&(ADC2->DR));	// Configure the peripheral data register address
	DMA2_Stream2->M0AR = (uint32_t)(ADC_array);		// Configure the memory address (note that M1AR is used for double-buffer mode)
	DMA2_Stream2->CR |= DMA_SxCR_CHSEL_0;			// channel select to 1 for ADC2

	DMA2_Stream2->CR |= DMA_SxCR_EN;				// Enable DMA2
	ADC2->CR2 |= ADC_CR2_ADON;						// Activate ADC
}

void InitIO()
{
	RCC->AHB1ENR |= RCC_AHB1ENR_GPIOAEN;			// reset and clock control - advanced high performance bus - GPIO port A
	RCC->AHB1ENR |= RCC_AHB1ENR_GPIOBEN;			// reset and clock control - advanced high performance bus - GPIO port B
	RCC->AHB1ENR |= RCC_AHB1ENR_GPIOCEN;			// reset and clock control - advanced high performance bus - GPIO port C
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



//	Setup Timer 9 to count clock cycles for coverage profiling
void InitCoverageTimer() {
	RCC->APB2ENR |= RCC_APB2ENR_TIM9EN;				// Enable Timer
	TIM9->PSC = 100;
	TIM9->ARR = 65535;

	TIM9->DIER |= TIM_DIER_UIE;						// DMA/interrupt enable register
	NVIC_EnableIRQ(TIM1_BRK_TIM9_IRQn);
	NVIC_SetPriority(TIM1_BRK_TIM9_IRQn, 2);		// Lower is higher priority

}




void InitSPI()
{
	//	Enable GPIO and SPI clocks
	RCC->AHB1ENR |= RCC_AHB1ENR_GPIOAEN;			// reset and clock control - advanced high performance bus - GPIO port A
	RCC->AHB1ENR |= RCC_AHB1ENR_GPIOBEN;			// reset and clock control - advanced high performance bus - GPIO port B
	RCC->APB1ENR |= RCC_APB1ENR_SPI3EN;

	// PB5: SPI_MOSI [alternate function AF6]
	GPIOB->MODER |= GPIO_MODER_MODER5_1;			// 00: Input (reset state)	01: General purpose output mode	10: Alternate function mode	11: Analog mode
	GPIOB->OSPEEDR |= GPIO_OSPEEDER_OSPEEDR5;		// V High  - 00: Low speed; 01: Medium speed; 10: High speed; 11: Very high speed
	GPIOB->AFR[0] |= 0b0110 << 20;					// 0b0110 = Alternate Function 6 (SPI3); 20 is position of Pin 5

	// PB3 SPI_SCK [alternate function AF6]
	GPIOB->MODER &= ~GPIO_MODER_MODER3;				// Reset value of PB3 is 0b10
	GPIOB->MODER |= GPIO_MODER_MODER3_1;			// 00: Input (reset state)	01: General purpose output mode	10: Alternate function mode	11: Analog mode
	GPIOB->OSPEEDR |= GPIO_OSPEEDER_OSPEEDR3;		// V High  - 00: Low speed; 01: Medium speed; 10: High speed; 11: Very high speed
	GPIOB->AFR[0] |= 0b0110 << 12;					// 0b0110 = Alternate Function 6 (SPI3); 12 is position of Pin 3

	SPI3->CR1 |= SPI_CR1_BR_2;						// Baud rate control prescaler: 0b001: fPCLK/4; 0b100: fPCLK/32
	SPI3->CR1 |= SPI_CR1_MSTR;						// Master selection
	SPI3->CR1 |= SPI_CR1_DFF;						// Use 16 bit data frame

	// Hardware NSS - use PA15 on pin 50
	GPIOA->MODER |= GPIO_MODER_MODER15_1;			// 00: Input (reset state)	01: General purpose output mode	10: Alternate function mode	11: Analog mode
	GPIOA->OSPEEDR |= GPIO_OSPEEDER_OSPEEDR15;		// V High  - 00: Low speed; 01: Medium speed; 10: High speed; 11: Very high speed
	GPIOA->AFR[1] |= 0b0110 << 28;					// 0b0110 = Alternate Function 6 (SPI3); 28 is position of Pin 15

//	// Hardware NSS - use PA4 on pin 20
//	GPIOA->MODER |= GPIO_MODER_MODER4_1;			// 00: Input (reset state)	01: General purpose output mode	10: Alternate function mode	11: Analog mode
//	GPIOA->OSPEEDR |= GPIO_OSPEEDER_OSPEEDR4;		// V High  - 00: Low speed; 01: Medium speed; 10: High speed; 11: Very high speed
//	GPIOA->AFR[0] |= 0b0110 << 16;					// 0b0110 = Alternate Function 6 (SPI3); 16 is position of Pin 4

	SPI3->CR1 &= ~SPI_CR1_SSM;						// Software slave management: When SSM bit is set, NSS pin input is replaced with the value from the SSI bit
	SPI3->CR2 |= SPI_CR2_SSOE;						// Uses hardware slave select - NSS line is pulled low when SPI enabled
}

void sendSPIData(uint16_t data) {
	while (((SPI3->SR & SPI_SR_TXE) == 0) | ((SPI3->SR & SPI_SR_BSY) == SPI_SR_BSY) );
	SPI3->CR1 |= SPI_CR1_SPE;
	SPI3->DR = data;		// Send cmd data [X X C C C A A A]
	while (((SPI3->SR & SPI_SR_TXE) == 0) | ((SPI3->SR & SPI_SR_BSY) == SPI_SR_BSY) );
	SPI3->CR1 &= ~SPI_CR1_SPE;

}

//	Setup Timer 3 on an interrupt to trigger SPI data send
void InitSPITimer() {
	RCC->APB1ENR |= RCC_APB1ENR_TIM3EN;				// Enable Timer 3
	TIM3->PSC = 50;									// Set prescaler
	TIM3->ARR = 140; 								// Set auto reload register

	TIM3->DIER |= TIM_DIER_UIE;						// DMA/interrupt enable register
	NVIC_EnableIRQ(TIM3_IRQn);
	NVIC_SetPriority(TIM3_IRQn, 0);					// Lower is higher priority

	TIM3->CR1 |= TIM_CR1_CEN;
	TIM3->EGR |= TIM_EGR_UG;						//  Re-initializes counter and generates update of registers
}






