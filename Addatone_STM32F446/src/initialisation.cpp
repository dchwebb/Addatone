#include "initialisation.h"

void InitHardware()
{
	InitClocks();
	InitMCO2();									// Initialise output of HSE oscillator on pin PC9
	InitSysTick();
	InitIO();
	InitFPGAProg();								// Initialise SPI peripheral used to program bitstream into FPGA
	InitSPI();
}


struct PLLDividers {
	uint32_t M;
	uint32_t N;
	uint32_t P;
	uint32_t Q;
};
const PLLDividers mainPLL {6, 144, 2, 2};		// Clock: 12MHz / 6 (M) * 144 (N) / 2 (P) = 144MHz

void InitClocks()
{
	RCC->APB1ENR |= RCC_APB1ENR_PWREN;			// Enable Power Control clock
	PWR->CR |= PWR_CR_VOS_0;					// Enable VOS voltage scaling - allows maximum clock speed

	SCB->CPACR |= ((3 << 10 * 2) | (3 << 11 * 2));	// CPACR register: set full access privileges for coprocessors

	RCC->CR |= RCC_CR_HSEON;					// HSE ON
	while ((RCC->CR & RCC_CR_HSERDY) == 0);		// Wait till HSE is ready

	RCC->PLLCFGR = 	(mainPLL.M << RCC_PLLCFGR_PLLM_Pos) |
					(mainPLL.N << RCC_PLLCFGR_PLLN_Pos) |
					(((mainPLL.P >> 1) - 1) << RCC_PLLCFGR_PLLP_Pos) |
					(mainPLL.Q << RCC_PLLCFGR_PLLQ_Pos) |
					RCC_PLLCFGR_PLLSRC_HSE;

	RCC->CFGR |= RCC_CFGR_HPRE_DIV1 |			// HCLK = SYSCLK / 1
				 RCC_CFGR_PPRE1_DIV4 |			// PCLK1 = HCLK / 4 (APB1)
				 RCC_CFGR_PPRE2_DIV2;			// PCLK2 = HCLK / 2 (APB2)

	RCC->CR |= RCC_CR_PLLON;					// Enable the main PLL
	while((RCC->CR & RCC_CR_PLLRDY) == 0);		// Wait till the main PLL is ready

	// Configure Flash prefetch, Instruction cache, Data cache and wait state
	FLASH->ACR = FLASH_ACR_PRFTEN | FLASH_ACR_ICEN | FLASH_ACR_DCEN | FLASH_ACR_LATENCY_5WS;

	// Select the main PLL as system clock source
	RCC->CFGR &= ~RCC_CFGR_SW;
	RCC->CFGR |= RCC_CFGR_SW_PLL;
	while ((RCC->CFGR & (uint32_t)RCC_CFGR_SWS ) != RCC_CFGR_SWS_PLL);

	// Enable data and instruction cache
	FLASH->ACR |= FLASH_ACR_ICEN;
	FLASH->ACR |= FLASH_ACR_DCEN;
	FLASH->ACR |= FLASH_ACR_PRFTEN;				// Enable the FLASH prefetch buffer

	SystemCoreClockUpdate();					// Update SystemCoreClock variable
}


void InitMCO2()
{
	// Initialise oscillator output on MCO2 pin PC9
	RCC->AHB1ENR |= RCC_AHB1ENR_GPIOCEN;
	GPIOC->MODER |= GPIO_MODER_MODER9_1;			// Set PC9 to Alternate function mode (0b10); Uses alternate function AF0 so set by default

	RCC->CFGR |= RCC_CFGR_MCO2_1; 					// 00: System clock; 01: PLLI2S clock; 10: HSE; 11: PLL clock
}


void InitAdcPins(ADC_TypeDef* ADC_No, std::initializer_list<uint8_t> channels)
{
	uint8_t sequence = 1;

	for (auto channel: channels) {
		// Set conversion sequence to order ADC channels are passed to this function
		if (sequence < 7) {
			ADC_No->SQR3 |= channel << ((sequence - 1) * 5);
		} else if (sequence < 13) {
			ADC_No->SQR2 |= channel << ((sequence - 7) * 5);
		} else {
			ADC_No->SQR1 |= channel << ((sequence - 13) * 5);
		}

		// 000: 3 cycles, 001: 15 cycles, 010: 28 cycles, 011: 56 cycles, 100: 84 cycles, 101: 112 cycles, 110: 144 cycles, 111: 480 cycles
		if (channel < 10) {
			ADC_No->SMPR2 |= 0b110 << (3 * channel);
		} else {
			ADC_No->SMPR1 |= 0b110 << (3 * (channel - 10));
		}

		sequence++;
	}
}


void InitADC()
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

	RCC->APB2ENR |= RCC_APB2ENR_ADC2EN;				// Enable ADC2 clock source

	// Enable ADC
	GpioPin::Init(GPIOA, 6, GpioPin::Type::Analog);
	GpioPin::Init(GPIOC, 3, GpioPin::Type::Analog);
	GpioPin::Init(GPIOA, 3, GpioPin::Type::Analog);
	GpioPin::Init(GPIOA, 7, GpioPin::Type::Analog);
	GpioPin::Init(GPIOA, 2, GpioPin::Type::Analog);
	GpioPin::Init(GPIOC, 5, GpioPin::Type::Analog);
	GpioPin::Init(GPIOB, 1, GpioPin::Type::Analog);
	GpioPin::Init(GPIOB, 0, GpioPin::Type::Analog);
	GpioPin::Init(GPIOC, 2, GpioPin::Type::Analog);
	GpioPin::Init(GPIOC, 0, GpioPin::Type::Analog);


	/* 446:
	0	PITCH_CV		PA6
	1	HARM1_CV		PC3
	2	HARM2_CV		PA3
	3	FREQ_SCALE_CV	PA7
	4	HARM_COUNT_POT	PA2
	5	CTUNE			PB1
	6	FTUNE			PC5
	7	HARM1_POT		PB0
	8	HARM2_POT		PC2
	9	FREQ_SC_POT		PC0
	*/

	ADC2->CR1 |= ADC_CR1_SCAN;						// Activate scan mode
	ADC2->SQR1 = (ADC_BUFFER_LENGTH - 1) << 20;		// Number of conversions in sequence
	InitAdcPins(ADC2, {6, 13, 3, 7, 2, 15, 9, 8, 12, 10});

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

	DMA2_Stream2->NDTR |= ADC_BUFFER_LENGTH * 4;	// Number of data items to transfer (ie size of ADC buffer)
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
	NVIC_SetPriority (SysTick_IRQn, 0);

	SysTick->VAL = 0;									// Reset the SysTick counter value

	SysTick->CTRL |= SysTick_CTRL_CLKSOURCE_Msk;		// Select processor clock: 1 = processor clock; 0 = external clock
	SysTick->CTRL |= SysTick_CTRL_TICKINT_Msk;			// Enable SysTick interrupt
	SysTick->CTRL |= SysTick_CTRL_ENABLE_Msk;			// Enable SysTick
}



//	Setup Timer 9 to count clock cycles for coverage profiling
void InitCoverageTimer()
{
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
	RCC->APB1ENR |= RCC_APB1ENR_SPI2EN;

	GpioPin::Init(GPIOB, 15, GpioPin::Type::AlternateFunction, 5, GpioPin::DriveStrength::VeryHigh);	// PB15: SPI_MOSI [alternate function AF5] to ICE_MOSI
	GpioPin::Init(GPIOB, 13, GpioPin::Type::AlternateFunction, 5, GpioPin::DriveStrength::VeryHigh);		// PB13: SPI_SCK [alternate function AF5]
	GpioPin::Init(GPIOB, 12, GpioPin::Type::Output);			// PB12 Software NSS
	GpioPin::SetHigh(GPIOB, 12);

	// PC7 Reset FPGA - configure as Open drain. This will only pull pin low when set to 0; otherwise output is high impedence
	RCC->AHB1ENR |= RCC_AHB1ENR_GPIOCEN;			// reset and clock control - advanced high performance bus - GPIO port C
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
	RCC->APB1ENR |= RCC_APB1ENR_SPI3EN;				//	Enable SPI clock

	GpioPin::Init(GPIOB, 5, GpioPin::Type::AlternateFunction, 6, GpioPin::DriveStrength::VeryHigh);		// PB5 (57): SPI_MOSI [AF6]
	GpioPin::Init(GPIOB, 3, GpioPin::Type::AlternateFunction, 6, GpioPin::DriveStrength::VeryHigh);		// PB3 (55) SPI_SCK [AF6]
	GpioPin::Init(GPIOA, 15, GpioPin::Type::Output);													// PA15 (50) Software NSS
	GpioPin::SetHigh(GPIOA, 15);

	// Configure SPI
	SPI3->CR1 |= SPI_CR1_DFF;						// Use 16 bit data frame
	SPI3->CR1 |= SPI_CR1_SSM;						// Software slave management: When SSM bit is set, NSS pin input is replaced with the value from the SSI bit
	SPI3->CR1 |= SPI_CR1_SSI;						// Internal slave select
	SPI3->CR1 |= SPI_CR1_BR_2;						// Baud rate control prescaler: 0b001: fPCLK/4; 0b100: fPCLK/32
	SPI3->CR1 |= SPI_CR1_MSTR;						// Master selection

	SPI3->CR1 |= SPI_CR1_SPE;						// Enable SPI
}


// Only used for testing
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


void sendI2SData(uint32_t data)
{
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


void sendSPIData(uint16_t data)
{
	while (((SPI3->SR & SPI_SR_TXE) == 0) | ((SPI3->SR & SPI_SR_BSY) == SPI_SR_BSY) );
	GPIOA->BSRR |= GPIO_BSRR_BR_15;
	SPI3->DR = data;		// Send cmd data [X X C C C A A A]
}


void clearSPI()
{
	while (((SPI3->SR & SPI_SR_TXE) == 0) | ((SPI3->SR & SPI_SR_BSY) == SPI_SR_BSY) );
	GPIOA->BSRR |= GPIO_BSRR_BS_15;
}


//	Setup Timer 3 on an interrupt to trigger SPI data send
void InitSPITimer()
{
	RCC->APB1ENR |= RCC_APB1ENR_TIM3EN;				// Enable Timer 3
	TIM3->PSC = 50;									// Set prescaler
	TIM3->ARR = 140; 								// Set auto reload register

	TIM3->DIER |= TIM_DIER_UIE;						// DMA/interrupt enable register
	NVIC_EnableIRQ(TIM3_IRQn);
	NVIC_SetPriority(TIM3_IRQn, 0);					// Lower is higher priority

	TIM3->CR1 |= TIM_CR1_CEN;
	TIM3->EGR |= TIM_EGR_UG;						//  Re-initializes counter and generates update of registers
}






