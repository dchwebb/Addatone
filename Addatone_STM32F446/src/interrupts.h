// SPI timer to trigger control update send to FPGA
void TIM3_IRQHandler(void) {
	fpga.SendControls();
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

