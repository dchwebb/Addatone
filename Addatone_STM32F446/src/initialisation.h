#pragma once


#include "stm32f4xx.h"
#include <algorithm>
#include <cmath>

extern volatile uint32_t SysTickVal;

#define ADC_BUFFER_LENGTH 10
extern volatile uint16_t ADC_array[ADC_BUFFER_LENGTH * 4];

// Define ADC array positions of various controls
#define PITCH_CV       0
#define HARM1_CV       1
#define HARM2_CV       2
#define WARP_CV        3
#define HARMCNT_POT    4
#define FTUNE_POT      5
#define CTUNE_POT      6
#define HARM1_POT      7
#define HARM2_POT      8
#define WARP_POT       9


void SystemClock_Config(void);
void InitMCO2();

void InitADC(void);
void InitIO(void);
void InitSysTick();
void InitCoverageTimer();

void InitFPGAProg();
void InitSPI();
void InitSPITimer();
void sendSPIData(uint16_t data);
void clearSPI();

void InitI2S();
void sendI2SData(uint32_t data);
