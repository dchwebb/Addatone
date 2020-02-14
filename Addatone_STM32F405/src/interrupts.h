// SPI Send timer
void TIM3_IRQHandler(void) {

	TIM3->SR &= ~TIM_SR_UIF;					// clear UIF flag

	// Pitch calculations
	//freq1 = 2299.0f * std::pow(2.0f, (float)Pitch / -583.0f);	// Increase 2299 to increase pitch; Reduce ABS(583) to increase spread

//	m.Offset = 2000			&& 2299
//	m.Spread = -690			&& -583
//	pitch = (float)((ADC_array[0] + ADC_array[2] + ADC_array[4] + ADC_array[6]) >> 2);
//	freq = 2270.0f * std::pow(2.0f, pitch / -610.0f);
//	freq += fup ? .01 : -.01;
//	if (freq > 230 || freq < 220) fup = !fup;

	freq = 200;
	sendSPIData((uint16_t)freq);

	// Send fine tune data as sum of four values (4 * 1024 = 4096) left shifted to create 16bit value (4096 << 2 = 65k)
	sendSPIData((uint16_t)(ADC_array[1] + ADC_array[3] + ADC_array[5] + ADC_array[7]) << 2);
//	sendSPIData((uint16_t)0b0101010100110011);

	clearSPI();
}

void SysTick_Handler(void) {
	SysTickVal++;
}

void NMI_Handler(void) {}

void HardFault_Handler(void) {
	while (1) {}
}

void MemManage_Handler(void) {
	while (1) {}
}

void BusFault_Handler(void) {
	while (1) {}
}

void UsageFault_Handler(void) {
	while (1) {}
}

void SVC_Handler(void) {}

void DebugMon_Handler(void) {}

void PendSV_Handler(void) {}

