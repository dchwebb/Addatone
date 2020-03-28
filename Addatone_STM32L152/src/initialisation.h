#pragma once


#include "stm32l1xx.h"
#include <algorithm>
#include <cmath>

extern volatile uint32_t SysTickVal;

#define ADC_BUFFER_LENGTH 5
extern volatile uint16_t ADC_array[ADC_BUFFER_LENGTH * 4];


void SystemClock_Config(void);
void InitADC(void);
void InitSimpleADC(void);
void InitIO(void);
void InitSysTick();
void InitCoverageTimer();

void InitSPI();
void InitSPITimer();
void sendSPIData(uint16_t data);
void clearSPI();

void InitI2S();
void sendI2SData(uint32_t data);
