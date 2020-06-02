#include "initialisation.h"

#define USE_HSE
#define PLL_M 6
#define PLL_N 144
#define PLL_P 2		//  Main PLL (PLL) division factor for main system clock can be 2 (PLL_P = 0), 4 (PLL_P = 1), 6 (PLL_P = 2), 8 (PLL_P = 3)
#define PLL_Q 2

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
	RCC->CFGR |= RCC_CFGR_PPRE2_DIV2;			// PCLK2 = HCLK / 2 (APB2)
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

void InitMCO2() {
	// Initialise oscillator output on MCO2 pin PC9
	RCC->AHB1ENR |= RCC_AHB1ENR_GPIOCEN;
	GPIOC->MODER |= GPIO_MODER_MODER9_1;			// Set PC9 to Alternate function mode (0b10); Uses alternate function AF0 so set by default

	RCC->CFGR |= RCC_CFGR_MCO2_1; 					// 00: System clock; 01: PLLI2S clock; 10: HSE; 11: PLL clock
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

	// Enable ADC
	GPIOA->MODER |= GPIO_MODER_MODER6;				// Set PA6 to Analog mode (0b11)
	GPIOC->MODER |= GPIO_MODER_MODER3;				// Set PC3 to Analog mode (0b11)
	GPIOA->MODER |= GPIO_MODER_MODER3;				// Set PA3 to Analog mode (á0b11)
	GPIOA->MODER |= GPIO_MODER_MODER7;				// Set PA7 to Analog mode (0b11)
	GPIOA->MODER |= GPIO_MODER_MODER2;				// Set PA2 to Analog mode (0b11)
	GPIOC->MODER |= GPIO_MODER_MODER5;				// Set PC5 to Analog mode (0b11)
	GPIOB->MODER |= GPIO_MODER_MODER1;				// Set PB1 to Analog mode (0b11)
	GPIOB->MODER |= GPIO_MODER_MODER0;				// Set PB0 to Analog mode (0b11)
	GPIOC->MODER |= GPIO_MODER_MODER2;				// Set PC2 to Analog mode (0b11)
	GPIOC->MODER |= GPIO_MODER_MODER0;				// Set PC0 to Analog mode (0b11)

	/* 446:
	PC0 ADC123_IN10
	PC1 ADC123_IN11
	PC2 ADC123_IN12
	PC3 ADC123_IN13
	PC4 ADC123_IN14
	PC5 ADC123_IN15

	PA0 ADC123_IN0
	PA1 ADC123_IN1
	PA2 ADC123_IN2
	PA3 ADC123_IN3
	PA4 ADC12_IN4
	PA5 ADC12_IN5
	PA6 ADC12_IN6
	PA7 ADC12_IN7

	PB0 ADC12_IN8
	PB1 ADC12_IN9

	0	PITCH_CV		PA6
	1	HARM1_CV		PC3
	2	HARM2_CV		PA3
	3	FREQ_SCALE_CV	PA7
	4	HARM_COUNT_POT	PA2
	5	FTUNE			PC5
	6	CTUNE			PB1
	7	HARM1_POT		PB0
	8	HARM2_POT		PC2
	9	FREQ_SC_POT		PC0
	*/

	ADC2->CR1 |= ADC_CR1_SCAN;						// Activate scan mode
	ADC2->SQR1 = (ADC_BUFFER_LENGTH - 1) << 20;		// Number of conversions in sequence
	ADC2->SQR3 |= 6 << 0;							// Set IN6  1st conversion in sequence
	ADC2->SQR3 |= 13 << 5;							// Set IN13 2nd conversion in sequence
	ADC2->SQR3 |= 3 << 10;							// Set IN3  3rd conversion in sequence
	ADC2->SQR3 |= 7 << 15;							// Set IN7  4th conversion in sequence
	ADC2->SQR3 |= 2 << 20;							// Set IN2  5th conversion in sequence
	ADC2->SQR3 |= 15 << 25;							// Set IN15 6th conversion in sequence
	ADC2->SQR2 |= 9 << 0;							// Set IN9  7th conversion in sequence
	ADC2->SQR2 |= 8 << 5;							// Set IN8  8th conversion in sequence
	ADC2->SQR2 |= 12 << 10;							// Set IN12 9th conversion in sequence
	ADC2->SQR2 |= 10 << 15;							// Set IN10 10th conversion in sequence

	//	Set to 56 cycles (0b11) sampling speed (SMPR2 Left shift speed 3 x ADC_INx up to input 9; use SMPR1 from 0 for ADC_IN10+)
	// 000: 3 cycles; 001: 15 cycles; 010: 28 cycles; 011: 56 cycles; 100: 84 cycles; 101: 112 cycles; 110: 144 cycles; 111: 480 cycles
	ADC2->SMPR2 |= 0b110 << 18;						// Set speed of IN6
	ADC2->SMPR1 |= 0b110 << 9;						// Set speed of IN13
	ADC2->SMPR2 |= 0b110 << 9;						// Set speed of IN3
	ADC2->SMPR2 |= 0b110 << 21;						// Set speed of IN7
	ADC2->SMPR2 |= 0b110 << 3;						// Set speed of IN2
	ADC2->SMPR1 |= 0b110 << 15;						// Set speed of IN15
	ADC2->SMPR2 |= 0b110 << 27;						// Set speed of IN9
	ADC2->SMPR2 |= 0b110 << 24;						// Set speed of IN8
	ADC2->SMPR1 |= 0b110 << 6;						// Set speed of IN12
	ADC2->SMPR1 |= 0b110 << 0;						// Set speed of IN10

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

void InitFPGAProg()
{
	//	Enable GPIO and SPI clocks
	RCC->AHB1ENR |= RCC_AHB1ENR_GPIOBEN;
	RCC->AHB1ENR |= RCC_AHB1ENR_GPIOCEN;
	RCC->APB1ENR |= RCC_APB1ENR_SPI2EN;

	// PB15: SPI_MOSI [alternate function AF5] to ICE_MOSI
	GPIOB->MODER |= GPIO_MODER_MODER15_1;			// 00: Input (reset state)	01: General purpose output mode	10: Alternate function mode	11: Analog mode
	GPIOB->OSPEEDR |= GPIO_OSPEEDER_OSPEEDR15;		// V High  - 00: Low speed; 01: Medium speed; 10: High speed; 11: Very high speed
	GPIOB->AFR[1] |= 0b0101 << 20;					// 0b0101 = Alternate Function 5 (SPI2); 20 is position of Pin 15

	// PB13: SPI_SCK [alternate function AF5]
	GPIOB->MODER |= GPIO_MODER_MODER13_1;			// 00: Input (reset state)	01: General purpose output mode	10: Alternate function mode	11: Analog mode
	GPIOB->OSPEEDR |= GPIO_OSPEEDER_OSPEEDR13;		// V High  - 00: Low speed; 01: Medium speed; 10: High speed; 11: Very high speed
	GPIOB->AFR[1] |= 0b0101 << 28;					// 0b0101 = Alternate Function 6 (SPI2); 28 is position of Pin 13

	// PB12 Software NSS
	GPIOB->MODER |= GPIO_MODER_MODER12_0;			// 00: Input (reset state)	01: General purpose output mode	10: Alternate function mode	11: Analog mode
	GPIOB->MODER &= ~GPIO_MODER_MODER12_1;
	GPIOB->BSRR |= GPIO_BSRR_BS_12;

	// PC7 Reset FPGA - configure as Open drain. This will only pull pin low when set to 0; otherwise output is high impedence
	GPIOC->OTYPER |= GPIO_OTYPER_OT7;				// Configure as open drain
	GPIOC->BSRR |= GPIO_BSRR_BS_7;
	GPIOC->MODER |= GPIO_MODER_MODER7_0;			// 00: Input (reset state)	01: General purpose output mode	10: Alternate function mode	11: Analog mode
	GPIOC->MODER &= ~GPIO_MODER_MODER7_1;

	// Configure SPI
	//SPI2->CR1 |= SPI_CR1_DFF;						// Use 16 bit data frame (default 8 bit)
	SPI2->CR1 |= SPI_CR1_SSM;						// Software slave management: When SSM bit is set, NSS pin input is replaced with the value from the SSI bit
	SPI2->CR1 |= SPI_CR1_SSI;						// Internal slave select
	SPI2->CR1 |= SPI_CR1_BR_0;						// Baud rate control prescaler: 0b001: fPCLK/4; 0b100: fPCLK/32
	SPI2->CR1 |= SPI_CR1_MSTR;						// Master selection
	SPI2->CR1 |= SPI_CR1_CPOL;						// Clock polarity (0: CK to 0 when idle; 1: CK to 1 when idle)

	SPI2->CR1 |= SPI_CR1_SPE;						// Enable SPI
}


void InitSPI()
{
	//	Enable GPIO and SPI clocks
	RCC->AHB1ENR |= RCC_AHB1ENR_GPIOAEN;			// reset and clock control - advanced high performance bus - GPIO port A
	RCC->AHB1ENR |= RCC_AHB1ENR_GPIOBEN;			// reset and clock control - advanced high performance bus - GPIO port B
	RCC->APB1ENR |= RCC_APB1ENR_SPI3EN;

	// PB5 (57): SPI_MOSI [alternate function AF6]
	GPIOB->MODER |= GPIO_MODER_MODER5_1;			// 00: Input (reset state)	01: General purpose output mode	10: Alternate function mode	11: Analog mode
	GPIOB->OSPEEDR |= GPIO_OSPEEDER_OSPEEDR5;		// V High  - 00: Low speed; 01: Medium speed; 10: High speed; 11: Very high speed
	GPIOB->AFR[0] |= 0b0110 << 20;					// 0b0110 = Alternate Function 6 (SPI3); 20 is position of Pin 5

	// PB3 (55) SPI_SCK [alternate function AF6]
	GPIOB->MODER &= ~GPIO_MODER_MODER3;				// Reset value of PB3 is 0b10
	GPIOB->MODER |= GPIO_MODER_MODER3_1;			// 00: Input (reset state)	01: General purpose output mode	10: Alternate function mode	11: Analog mode
	GPIOB->OSPEEDR |= GPIO_OSPEEDER_OSPEEDR3;		// V High  - 00: Low speed; 01: Medium speed; 10: High speed; 11: Very high speed
	GPIOB->AFR[0] |= 0b0110 << 12;					// 0b0110 = Alternate Function 6 (SPI3); 12 is position of Pin 3

	// PA15 (50) Software NSS
	GPIOA->MODER |= GPIO_MODER_MODER15_0;			// 00: Input (reset state)	01: General purpose output mode	10: Alternate function mode	11: Analog mode
	GPIOA->MODER &= ~GPIO_MODER_MODER15_1;
	GPIOA->BSRR |= GPIO_BSRR_BS_15;

	// Configure SPI
	SPI3->CR1 |= SPI_CR1_DFF;						// Use 16 bit data frame
	SPI3->CR1 |= SPI_CR1_SSM;						// Software slave management: When SSM bit is set, NSS pin input is replaced with the value from the SSI bit
	SPI3->CR1 |= SPI_CR1_SSI;						// Internal slave select
	SPI3->CR1 |= SPI_CR1_BR_2;						// Baud rate control prescaler: 0b001: fPCLK/4; 0b100: fPCLK/32
	SPI3->CR1 |= SPI_CR1_MSTR;						// Master selection

	SPI3->CR1 |= SPI_CR1_SPE;						// Enable SPI
}

void InitI2S()
{
	/* All AF5
	PC3 I2S2_SD
	PC6 I2S2_MCK
	[PC9 I2S_CKIN]

	62 PB9 I2S2_WS
	PB10 I2S2_CK
	33 PB12 I2S2_WS
	34 PB13 I2S2_CK
	[PB14 I2S2ext_SD]
	36 PB15 I2S2_SD

	*/
	//	Enable GPIO and SPI clocks
	RCC->AHB1ENR |= RCC_AHB1ENR_GPIOBEN;			// reset and clock control - advanced high performance bus - GPIO port B
	RCC->APB1ENR |= RCC_APB1ENR_SPI2EN;

/*
	// PB12: I2S2_WS [alternate function AF5]
	GPIOB->MODER |= GPIO_MODER_MODER12_1;			// 00: Input (reset state)	01: General purpose output mode	10: Alternate function mode	11: Analog mode
	GPIOB->OSPEEDR |= GPIO_OSPEEDER_OSPEEDR12;		// V High  - 00: Low speed; 01: Medium speed; 10: High speed; 11: Very high speed
	GPIOB->AFR[1] |= 0b0101 << 16;					// 0b0101 = Alternate Function 5 (I2S2); 16 is position of Pin 12
*/

	// PB9: I2S2_WS [alternate function AF5]
	GPIOB->MODER |= GPIO_MODER_MODER9_1;			// 00: Input (reset state)	01: General purpose output mode	10: Alternate function mode	11: Analog mode
	GPIOB->AFR[1] |= 0b0101 << 4;					// 0b0101 = Alternate Function 5 (I2S2); 4 is position of Pin 9

	// PB13 I2S2_CK [alternate function AF5]
	GPIOB->MODER |= GPIO_MODER_MODER13_1;			// 00: Input (reset state)	01: General purpose output mode	10: Alternate function mode	11: Analog mode
	//GPIOB->OSPEEDR |= GPIO_OSPEEDER_OSPEEDR13;		// V High  - 00: Low speed; 01: Medium speed; 10: High speed; 11: Very high speed
	GPIOB->AFR[1] |= 0b0101 << 20;					// 0b0101 = Alternate Function 6 (I2S2); 20 is position of Pin 13

	// PB15 I2S2_SD [alternate function AF5]
	GPIOB->MODER |= GPIO_MODER_MODER15_1;			// 00: Input (reset state)	01: General purpose output mode	10: Alternate function mode	11: Analog mode
	//GPIOB->OSPEEDR |= GPIO_OSPEEDER_OSPEEDR15;		// V High  - 00: Low speed; 01: Medium speed; 10: High speed; 11: Very high speed
	GPIOB->AFR[1] |= 0b0101 << 28;					// 0b0101 = Alternate Function 6 (I2S2); 28 is position of Pin 15

	// Configure SPI
	SPI2->I2SCFGR |= SPI_I2SCFGR_I2SMOD;			// I2S Mode
	SPI2->I2SCFGR |= SPI_I2SCFGR_I2SCFG_1;			// I2S configuration mode: 00=Slave transmit; 01=Slave receive; 10=Master transmit; 11=Master receive
//	SPI2->I2SCFGR |= SPI2_I2SCFGR_I2SSTD;			// I2S standard selection:	00=Philips; 01=MSB justified; 10=LSB justified; 11=PCM
	SPI2->I2SCFGR |= SPI_I2SCFGR_DATLEN_1;			// Data Length 00=16-bit; 01=24-bit; 10=32-bit
	SPI2->I2SCFGR |= SPI_I2SCFGR_CHLEN;				// Channel Length = 32bits

	/* RCC Clock calculations:
	f[VCO clock] = f[PLLI2S clock input] x (PLLI2SN / PLLM)		Eg (8MHz osc) * (192 / 4) = 384MHz
	f[PLL I2S clock output] = f[VCO clock] / PLLI2SR			Eg 384 / 5 = 76.8MHz
	*/

	/*
	RCC->DCKCFGR
	00: I2S2 clock frequency = f(PLLI2S_R);
	01: I2S2 clock frequency = I2S_CKIN Alternate function input frequency
	10: I2S2 clock frequency = f(PLL_R)
	11: I2S2 clock frequency = HSI/HSE depends on PLLSRC bit (PLLCFGR[22])

	RCC->PLLI2SCFGR
	Def: M = 16; N = 192; Q = 4; R = 2
	Try: M = 4; N = 77; R = 2		ie 8Mz * 77 / 4 / 2 = 77MHz
	*/
	//RCC->CFGR &= ~RCC_CFGR_I2SSRC;					// Set I2S PLL source to internal
	RCC->PLLI2SCFGR = (RCC_PLLI2SCFGR_PLLI2SM & 4) | (RCC_PLLI2SCFGR_PLLI2SN & (77 << 6)) | (RCC_PLLI2SCFGR_PLLI2SR & (2 << 28));			//p 163
	RCC->CR |= RCC_CR_PLLI2SON;

	/* I2S Prescaler Clock calculations:
	FS = I2SxCLK / [(32*2)*((2*I2SDIV)+ODD))]					Eg  76.8 / (64 * ((2 * 12) + 1)) = 48kHz
	*/
	SPI2->I2SPR = (SPI_I2SPR_I2SDIV & 12) | SPI_I2SPR_ODD;		// Set Linear prescaler to 12 and enable Odd factor prescaler

	SPI2->I2SCFGR |= SPI_I2SCFGR_I2SE;				// Enable I2S
}

void sendI2SData(uint32_t data) {
	//while (((SPI2->SR & SPI_SR_TXE) == 0) | ((SPI2->SR & SPI_SR_BSY) == SPI_SR_BSY) );
	while ((SPI2->SR & SPI_SR_TXE) == 0);
	SPI2->DR = 0x5533;
	while ((SPI2->SR & SPI_SR_TXE) == 0);
	SPI2->DR = 0xAABB;
	while ((SPI2->SR & SPI_SR_TXE) == 0);
	SPI2->DR = 0x5533;
	while ((SPI2->SR & SPI_SR_TXE) == 0);
	SPI2->DR = 0xAABB;

}


void sendSPIData(uint16_t data) {
	while (((SPI3->SR & SPI_SR_TXE) == 0) | ((SPI3->SR & SPI_SR_BSY) == SPI_SR_BSY) );
	GPIOA->BSRR |= GPIO_BSRR_BR_15;
	SPI3->DR = data;		// Send cmd data [X X C C C A A A]
}

void clearSPI() {
	while (((SPI3->SR & SPI_SR_TXE) == 0) | ((SPI3->SR & SPI_SR_BSY) == SPI_SR_BSY) );
	GPIOA->BSRR |= GPIO_BSRR_BS_15;
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






