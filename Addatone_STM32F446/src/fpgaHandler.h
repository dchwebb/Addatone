#pragma once

#include "initialisation.h"
#include "configManager.h"

// create macro to enable summing of four most recent values of ADC regardless of how many ADC samples are in the buffer
#define ADC_SUM(x) (ADC_array[x] + ADC_array[ADC_BUFFER_LENGTH + x] + ADC_array[ADC_BUFFER_LENGTH * 2 + x] + ADC_array[ADC_BUFFER_LENGTH * 3 + x])
#define ADC_REV(x) 16384 - ADC_SUM(x)


struct fpgaHandler {
public:
	void ProgramBitstream();
	void SendControls();

	ConfigSaver configSaver = {
		.settingsAddress = &cfg,
		.settingsSize = sizeof(cfg),
		.validateSettings = nullptr
	};

	Btn calibBtn {GPIOC, 13, GpioPin::Type::InputPullup};

private:
	struct Config {
		float calibSpread = 590.0f;			// Used to calculate tuning spread
		float calibFineTuneMid = 8192.0f;	// To enable setting of fine tune mid point
	} cfg;

	bool calibrating = false;
	int32_t calibSpreadStart;				// Read initial position of coarse tune knob as used to set spread
	float calibSpreadOrig = cfg.calibSpread;// Store original spread amount so can dynamically adjust whilst calibrating

	uint16_t coarseTune;					// Octave tuning with hysteresis
	float freq = 220;						// Frequency adjusted for FPGA's cycle of 65k

	uint16_t dampedHarmonicScaleOdd;		// Combined pot and cv values for odd harmonics with damping
	float harmScaleOdd;						// Odd harmonic level converted to exponential scale with additional damping
	uint16_t startVolOdd;					// Starting volume before exponential reduction applied

	uint16_t dampedHarmonicScaleEven;
	float harmScaleEven;
	uint16_t startVolEven;

	int16_t freqScale;						// Frequency scaling
	uint16_t harmCount;						// Number of harmonics
	float harmCountDamped;
	float harmCountHysteresis;				// Temporary value used for hysteresis

};

extern fpgaHandler fpga;
