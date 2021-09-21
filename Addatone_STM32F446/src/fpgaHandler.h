#pragma once

#include "initialisation.h"

struct fpgaHandler {
public:
	void ProgramBitstream();
	void SendControls();

private:
	uint16_t coarseTune;				// Octave tuning with hysteresis
	float freq = 220;					// Frequency adjusted for FPGA's cycle of 65k

	uint16_t dampedHarmonicScaleOdd;	// Combined pot and cv values for odd harmonics with damping
	float harmScaleOdd;					// Odd harmonic level converted to exponential scale with additional damping
	uint16_t startVolOdd;				// Starting volume before exponential reduction applied

	uint16_t dampedHarmonicScaleEven;
	float harmScaleEven;
	uint16_t startVolEven;

	int16_t freqScale;					// Frequency scaling
	uint16_t harmCount;					// Number of harmonics
	float harmCountDamped;
	float harmCountHysteresis;			// Temporary value used for hysteresis
};
