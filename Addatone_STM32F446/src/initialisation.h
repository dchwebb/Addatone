#pragma once

#include "stm32f4xx.h"
#include <algorithm>
#include <cmath>
#include "GpioPin.h"

extern volatile uint32_t SysTickVal;

#define ADC_BUFFER_LENGTH 10
extern volatile uint16_t ADC_array[ADC_BUFFER_LENGTH * 4];
enum ADC_Controls {
	ADC_Pitch      = 0,       // PA6
	ADC_Harm1CV    = 1,       // PC3
	ADC_Harm2CV    = 2,       // PA3
	ADC_WarpCV     = 3,       // PA7
	ADC_HarmCntPot = 4,       // PA2
	ADC_CTune      = 5,       // PB1
	ADC_FTune      = 6,       // PC5
	ADC_Harm1Pot   = 7,       // PB0
	ADC_Harm2Pot   = 8,       // PC2
	ADC_WarpPot    = 9,       // PC0
};

void InitHardware();
void InitClocks();
void InitMCO2();

void InitADC();
void InitIO();
void InitSysTick();
void InitCoverageTimer();

void InitFPGAProg();
void InitSPI();
void InitSPITimer();
void sendSPIData(uint16_t data);
void clearSPI();

void InitI2S();
void sendI2SData(uint32_t data);
